import asyncio
import json
import os
import socket
import tempfile
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


BLOCKED_STATUS_CODES = {403}

BLOCKED_URL_MARKERS = (
    "cdn-cgi/challenge-platform",
    "cloudflare",
    "openathens",
    "shibboleth",
    "/saml",
    "saml2",
    "wayf",
    "idp",
    "identityprovider",
    "institution",
    "federation",
    "login",
    "signin",
    "authorize",
    "authentication",
    "webofscience",
    "webofknowledge",
    "clarivate",
    "ieee.org",
    "ieee.com",
)

STRONG_BODY_MARKERS = (
    "verify you are human",
    "checking if the site connection is secure",
    "just a moment",
    "cf-challenge",
    "cf-turnstile",
    "challenge-platform",
    "cloudflare ray id",
    "attention required",
    "browser check",
    "captcha",
    "are you a robot",
)

AUTH_BODY_MARKERS = (
    "openathens",
    "shibboleth",
    "institutional sign in",
    "institutional login",
    "institutional access",
    "select your institution",
    "single sign-on",
    "single sign on",
    "identity provider",
    "federated login",
    "university login",
    "saml",
    "web of science",
    "webofscience",
    "clarivate",
    "ieee xplore",
)

AUTH_PAGE_CUES = (
    'type="password"',
    "name=\"password\"",
    "name='password'",
    "name=\"username\"",
    "name='username'",
    "samlrequest",
    "samlresponse",
    "oauth",
    "openid",
    "<form",
)


@dataclass(frozen=True)
class HumanAuthPaths:
    storage_state: str
    session_storage: str
    context_meta: str


def _coerce_bool(value: Any, default: bool = False) -> bool:
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    return str(value).strip().lower() not in {"0", "false", "no", "off", ""}


def _coerce_int(value: Any, default: int) -> int:
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _json_load(path: str, default: Any) -> Any:
    if not path or not os.path.exists(path):
        return default
    try:
        with open(path, "r", encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, json.JSONDecodeError):
        return default


def _json_dump_atomic(path: str, data: Any) -> None:
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(
        prefix=f".{Path(path).name}.",
        suffix=".tmp",
        dir=str(Path(path).parent),
        text=True,
    )
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as fh:
            json.dump(data, fh, indent=2, ensure_ascii=False)
            fh.write("\n")
        os.replace(tmp_path, path)
    finally:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)


def _with_query_params(url: str, params: dict[str, str]) -> str:
    parsed = urllib.parse.urlsplit(url)
    query = dict(urllib.parse.parse_qsl(parsed.query, keep_blank_values=True))
    for key, value in params.items():
        if value and key not in query:
            query[key] = value
    return urllib.parse.urlunsplit(
        (
            parsed.scheme,
            parsed.netloc,
            parsed.path,
            urllib.parse.urlencode(query),
            parsed.fragment,
        )
    )


def _http_base_from_ws_url(url: str) -> str:
    parsed = urllib.parse.urlsplit(url)
    scheme = "https" if parsed.scheme == "wss" else "http"
    return urllib.parse.urlunsplit((scheme, parsed.netloc, "", "", ""))


def _query_value(url: str, name: str) -> str:
    parsed = urllib.parse.urlsplit(url)
    return dict(urllib.parse.parse_qsl(parsed.query, keep_blank_values=True)).get(name, "")


def _normalize_browserless_url(url: str, public_base: str, token: str = "") -> str:
    if not url:
        return url
    if url.startswith("/"):
        url = public_base.rstrip("/") + url
    if token and "token=" not in urllib.parse.urlsplit(url).query:
        url = _with_query_params(url, {"token": token})
    return url


def _http_get_json(url: str, timeout: float = 5.0) -> Any:
    request = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return json.loads(response.read().decode("utf-8"))


async def _read_http_request(reader: asyncio.StreamReader) -> tuple[str, str, dict[str, str], bytes]:
    head = await reader.readuntil(b"\r\n\r\n")
    header_text = head.decode("iso-8859-1")
    lines = header_text.split("\r\n")
    method, target, _version = lines[0].split(" ", 2)
    headers: dict[str, str] = {}
    for line in lines[1:]:
        if not line or ":" not in line:
            continue
        name, value = line.split(":", 1)
        headers[name.strip().lower()] = value.strip()
    body = b""
    length = int(headers.get("content-length", "0") or "0")
    if length:
        body = await reader.readexactly(length)
    return method, target, headers, body


async def _write_http_response(
    writer: asyncio.StreamWriter,
    status: str,
    content_type: str,
    body: bytes,
) -> None:
    headers = (
        f"HTTP/1.1 {status}\r\n"
        f"Content-Type: {content_type}\r\n"
        f"Content-Length: {len(body)}\r\n"
        "Cache-Control: no-store\r\n"
        "Connection: close\r\n"
        "\r\n"
    ).encode("ascii")
    writer.write(headers + body)
    await writer.drain()


class HumanAuthRelayServer:
    def __init__(self, page, host: str, port: int, public_url: str, logger):
        self.page = page
        self.host = host
        self.port = port
        self.public_url = public_url.rstrip("/") if public_url else ""
        self.logger = logger
        self.server: asyncio.base_events.Server | None = None
        self._page_lock = asyncio.Lock()

    async def start(self) -> str:
        try:
            self.server = await asyncio.start_server(self._handle_client, self.host, self.port)
        except OSError:
            self.server = await asyncio.start_server(self._handle_client, self.host, 0)

        sockets = self.server.sockets or []
        actual_port = sockets[0].getsockname()[1] if sockets else self.port
        if self.public_url:
            return self.public_url
        host = "127.0.0.1" if self.host in {"", "0.0.0.0", "::"} else self.host
        return f"http://{host}:{actual_port}"

    async def stop(self) -> None:
        if self.server is None:
            return
        self.server.close()
        await self.server.wait_closed()
        self.server = None

    async def _handle_client(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter) -> None:
        try:
            method, target, _headers, body = await _read_http_request(reader)
            parsed = urllib.parse.urlsplit(target)
            if method == "GET" and parsed.path in {"/", "/index.html"}:
                await _write_http_response(
                    writer,
                    "200 OK",
                    "text/html; charset=utf-8",
                    self._index_html().encode("utf-8"),
                )
            elif method == "GET" and parsed.path == "/screenshot.jpg":
                async with self._page_lock:
                    image = await self.page.screenshot(type="jpeg", quality=70, full_page=False)
                await _write_http_response(writer, "200 OK", "image/jpeg", image)
            elif method == "GET" and parsed.path == "/state":
                async with self._page_lock:
                    state = {
                        "url": self.page.url,
                        "title": await self.page.title(),
                    }
                await _write_http_response(
                    writer,
                    "200 OK",
                    "application/json",
                    json.dumps(state).encode("utf-8"),
                )
            elif method == "POST" and parsed.path == "/mouse":
                await self._handle_mouse(body)
                await _write_http_response(writer, "200 OK", "application/json", b'{"ok":true}')
            elif method == "POST" and parsed.path == "/key":
                await self._handle_key(body)
                await _write_http_response(writer, "200 OK", "application/json", b'{"ok":true}')
            elif method == "POST" and parsed.path == "/type":
                await self._handle_type(body)
                await _write_http_response(writer, "200 OK", "application/json", b'{"ok":true}')
            else:
                await _write_http_response(writer, "404 Not Found", "text/plain", b"not found")
        except Exception as exc:
            self.logger.warning("Human auth relay request failed: %s", exc)
            try:
                await _write_http_response(
                    writer,
                    "500 Internal Server Error",
                    "text/plain",
                    b"relay error",
                )
            except Exception:
                pass
        finally:
            writer.close()
            try:
                await writer.wait_closed()
            except Exception:
                pass

    async def _handle_mouse(self, body: bytes) -> None:
        data = json.loads(body.decode("utf-8") or "{}")
        action = data.get("action", "click")
        x = float(data.get("x", 0))
        y = float(data.get("y", 0))
        async with self._page_lock:
            if action == "move":
                await self.page.mouse.move(x, y)
            elif action == "wheel":
                await self.page.mouse.wheel(float(data.get("deltaX", 0)), float(data.get("deltaY", 0)))
            else:
                await self.page.mouse.click(x, y, button=data.get("button", "left"))

    async def _handle_key(self, body: bytes) -> None:
        data = json.loads(body.decode("utf-8") or "{}")
        key = str(data.get("key") or "")
        if not key:
            return
        async with self._page_lock:
            if len(key) == 1:
                await self.page.keyboard.type(key)
            else:
                await self.page.keyboard.press(key)

    async def _handle_type(self, body: bytes) -> None:
        data = json.loads(body.decode("utf-8") or "{}")
        text = str(data.get("text") or "")
        if not text:
            return
        async with self._page_lock:
            await self.page.keyboard.type(text, delay=20)

    @staticmethod
    def _index_html() -> str:
        return """<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Human Authorization Relay</title>
  <style>
    body { margin: 0; font: 14px system-ui, sans-serif; background: #111; color: #eee; }
    header { padding: 8px 10px; background: #222; display: flex; gap: 8px; align-items: center; }
    input { width: min(520px, 50vw); padding: 6px; }
    button { padding: 6px 10px; }
    #status { opacity: .8; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    #screen { display: block; max-width: 100vw; width: 100vw; height: auto; cursor: crosshair; }
  </style>
</head>
<body>
  <header>
    <button id="refresh">Refresh</button>
    <input id="text" placeholder="Type text here, then click Type">
    <button id="type">Type</button>
    <span id="status"></span>
  </header>
  <img id="screen" alt="browser screen">
  <script>
    const screen = document.getElementById('screen');
    const statusEl = document.getElementById('status');
    async function post(path, data) {
      await fetch(path, {method: 'POST', headers: {'Content-Type': 'application/json'}, body: JSON.stringify(data)});
    }
    async function refresh() {
      screen.src = '/screenshot.jpg?t=' + Date.now();
      try {
        const state = await fetch('/state?t=' + Date.now()).then(r => r.json());
        statusEl.textContent = state.title + ' - ' + state.url;
      } catch (err) {}
    }
    screen.addEventListener('click', async (event) => {
      const rect = screen.getBoundingClientRect();
      const scaleX = screen.naturalWidth / rect.width;
      const scaleY = screen.naturalHeight / rect.height;
      await post('/mouse', {action: 'click', x: (event.clientX - rect.left) * scaleX, y: (event.clientY - rect.top) * scaleY});
      setTimeout(refresh, 350);
    });
    screen.addEventListener('wheel', async (event) => {
      event.preventDefault();
      await post('/mouse', {action: 'wheel', deltaX: event.deltaX, deltaY: event.deltaY});
      setTimeout(refresh, 250);
    }, {passive: false});
    window.addEventListener('keydown', async (event) => {
      if (event.target && event.target.tagName === 'INPUT') return;
      event.preventDefault();
      await post('/key', {key: event.key});
      setTimeout(refresh, 250);
    });
    document.getElementById('type').addEventListener('click', async () => {
      const input = document.getElementById('text');
      await post('/type', {text: input.value});
      input.value = '';
      setTimeout(refresh, 250);
    });
    document.getElementById('refresh').addEventListener('click', refresh);
    screen.addEventListener('load', () => setTimeout(refresh, 900));
    refresh();
  </script>
</body>
</html>
"""


def state_paths(storage_state_path: str) -> HumanAuthPaths:
    return HumanAuthPaths(
        storage_state=storage_state_path,
        session_storage=f"{storage_state_path}.session_storage.json",
        context_meta=f"{storage_state_path}.context.json",
    )


def detect_human_auth_block(response) -> str | None:
    url_lower = (response.url or "").lower()

    for marker in BLOCKED_URL_MARKERS:
        if marker in url_lower:
            return f"url marker: {marker}"

    body_lower = ""
    try:
        body_lower = response.text[:200_000].lower()
    except Exception:
        body_lower = ""

    for marker in STRONG_BODY_MARKERS:
        if marker in body_lower:
            return f"body marker: {marker}"

    for marker in AUTH_BODY_MARKERS:
        if marker in body_lower and any(cue in body_lower for cue in AUTH_PAGE_CUES):
            return f"auth page marker: {marker}"

    if response.status in BLOCKED_STATUS_CODES:
        return f"http status: {response.status}"

    return None


def is_human_auth_blocked(response) -> bool:
    return detect_human_auth_block(response) is not None


def load_context_meta(storage_state_path: str) -> dict[str, Any]:
    paths = state_paths(storage_state_path)
    data = _json_load(paths.context_meta, {})
    return data if isinstance(data, dict) else {}


def apply_context_overrides(context_kwargs: dict[str, Any], storage_state_path: str) -> dict[str, Any]:
    meta = load_context_meta(storage_state_path)
    overrides = meta.get("context_kwargs") if isinstance(meta, dict) else None
    if not isinstance(overrides, dict):
        return context_kwargs

    for key in ("user_agent", "viewport", "timezone_id", "locale", "extra_http_headers"):
        value = overrides.get(key)
        if value:
            context_kwargs[key] = value
    return context_kwargs


def session_storage_init_script(storage_state_path: str) -> str | None:
    paths = state_paths(storage_state_path)
    data = _json_load(paths.session_storage, {})
    origins = data.get("origins") if isinstance(data, dict) else None
    if not isinstance(origins, list):
        return None

    by_origin: dict[str, dict[str, str]] = {}
    for origin_data in origins:
        if not isinstance(origin_data, dict):
            continue
        origin = origin_data.get("origin")
        entries = origin_data.get("sessionStorage")
        if not origin or not isinstance(entries, list):
            continue
        values: dict[str, str] = {}
        for entry in entries:
            if not isinstance(entry, dict):
                continue
            name = entry.get("name")
            value = entry.get("value")
            if name is not None and value is not None:
                values[str(name)] = str(value)
        if values:
            by_origin[str(origin)] = values

    if not by_origin:
        return None

    payload = json.dumps(by_origin, ensure_ascii=False)
    return f"""
(() => {{
  const stores = {payload};
  const entries = stores[window.location.origin];
  if (!entries) return;
  for (const [key, value] of Object.entries(entries)) {{
    try {{
      window.sessionStorage.setItem(key, value);
    }} catch (err) {{}}
  }}
}})();
"""


def update_request_with_authorized_state(request, storage_state_path: str) -> None:
    kwargs = dict(request.meta.get("playwright_context_kwargs") or {})
    if storage_state_path and os.path.exists(storage_state_path):
        kwargs["storage_state"] = storage_state_path
        apply_context_overrides(kwargs, storage_state_path)
    request.meta["playwright_context_kwargs"] = kwargs
    request.meta["human_auth_storage_state_path"] = storage_state_path


async def _collect_session_storage(context) -> dict[str, Any]:
    origins: dict[str, list[dict[str, str]]] = {}
    for page in list(context.pages):
        try:
            origin = await page.evaluate("() => window.location.origin")
            entries = await page.evaluate(
                """() => {
                    const items = [];
                    for (let i = 0; i < window.sessionStorage.length; i += 1) {
                        const name = window.sessionStorage.key(i);
                        items.push({name, value: window.sessionStorage.getItem(name)});
                    }
                    return items;
                }"""
            )
        except Exception:
            continue

        if origin and entries:
            origins[str(origin)] = [
                {"name": str(item["name"]), "value": str(item["value"])}
                for item in entries
                if isinstance(item, dict) and item.get("name") is not None
            ]

    return {
        "saved_at": datetime.now(timezone.utc).isoformat(),
        "origins": [
            {"origin": origin, "sessionStorage": entries}
            for origin, entries in sorted(origins.items())
            if entries
        ],
    }


async def _visible_page_context_kwargs(page, fallback: dict[str, Any]) -> dict[str, Any]:
    kwargs = {
        "user_agent": fallback.get("user_agent"),
        "viewport": fallback.get("viewport"),
        "timezone_id": fallback.get("timezone_id"),
        "locale": fallback.get("locale", "en-US"),
        "extra_http_headers": fallback.get("extra_http_headers"),
    }
    try:
        ua = await page.evaluate("() => navigator.userAgent")
        if ua:
            kwargs["user_agent"] = ua
    except Exception:
        pass
    try:
        viewport = await page.evaluate(
            "() => ({width: window.innerWidth, height: window.innerHeight})"
        )
        if isinstance(viewport, dict) and viewport.get("width") and viewport.get("height"):
            kwargs["viewport"] = {
                "width": int(viewport["width"]),
                "height": int(viewport["height"]),
            }
    except Exception:
        pass
    return {key: value for key, value in kwargs.items() if value}


class BrowserlessHumanAuthorizer:
    def __init__(self, crawler):
        self.crawler = crawler
        self.settings = crawler.settings

    @property
    def enabled(self) -> bool:
        return _coerce_bool(self.settings.get("HUMAN_AUTH_ENABLED"), default=True)

    @property
    def cdp_url(self) -> str:
        return (
            self.settings.get("BROWSERLESS_CDP_URL")
            or self.settings.get("BROWSERLESS_WS_ENDPOINT")
            or ""
        )

    def _browserless_cdp_url(self) -> str:
        timeout = str(
            _coerce_int(
                self.settings.get("BROWSERLESS_SESSION_TIMEOUT_MS"),
                _coerce_int(self.settings.get("BROWSERLESS_LIVE_TIMEOUT_MS"), 15 * 60 * 1000),
            )
        )
        return _with_query_params(self.cdp_url, {"timeout": timeout})

    async def authorize(self, url: str, reason: str, spider) -> bool:
        return await self.authorize_with_state(
            url,
            reason,
            spider,
            self.settings.get("SD_STATE_PATH", ""),
        )

    async def authorize_with_state(
        self,
        url: str,
        reason: str,
        spider,
        state_path: str,
    ) -> bool:
        if not self.enabled:
            spider.logger.warning("Human authorization disabled; cannot resolve %s", url)
            return False
        if not self.cdp_url:
            spider.logger.error(
                "Human authorization required for %s (%s), but BROWSERLESS_CDP_URL is not set.",
                url,
                reason,
            )
            return False

        try:
            from playwright.async_api import async_playwright
        except ImportError as exc:
            spider.logger.error("Playwright is not available for human authorization: %s", exc)
            return False

        paths = state_paths(state_path)
        live_timeout = _coerce_int(
            self.settings.get("BROWSERLESS_LIVE_TIMEOUT_MS"),
            15 * 60 * 1000,
        )
        navigation_timeout = _coerce_int(
            self.settings.get("HUMAN_AUTH_NAVIGATION_TIMEOUT_MS"),
            90_000,
        )
        connect_timeout = _coerce_int(
            self.settings.get("BROWSERLESS_CONNECT_TIMEOUT_MS"),
            30_000,
        )
        session_label = f"spider-human-auth-{datetime.now(timezone.utc).strftime('%Y%m%d%H%M%S')}"
        cdp_url = self._browserless_cdp_url()
        context_kwargs = self._browserless_context_kwargs(state_path)

        browser = None
        context = None
        relay = None
        try:
            async with async_playwright() as pw:
                browser = await pw.chromium.connect_over_cdp(
                    cdp_url,
                    timeout=connect_timeout,
                )
                context = await browser.new_context(**context_kwargs)
                page = await context.new_page()
                page.set_default_navigation_timeout(navigation_timeout)
                try:
                    await page.goto(url, wait_until="domcontentloaded", timeout=navigation_timeout)
                except Exception as exc:
                    spider.logger.warning(
                        "Initial Browserless navigation did not complete for %s: %s. "
                        "Continuing with live session.",
                        url,
                        exc,
                    )
                cdp = await context.new_cdp_session(page)
                access_url, access_kind = await self._browser_access_url(
                    cdp,
                    session_label,
                    live_timeout,
                    spider,
                )
                if not access_url:
                    relay = HumanAuthRelayServer(
                        page,
                        self.settings.get("HUMAN_AUTH_RELAY_HOST", "0.0.0.0"),
                        _coerce_int(self.settings.get("HUMAN_AUTH_RELAY_PORT"), 8765),
                        self.settings.get("HUMAN_AUTH_RELAY_PUBLIC_URL", ""),
                        spider.logger,
                    )
                    access_url = await relay.start()
                    access_kind = "built-in screenshot relay fallback"

                if not access_url:
                    spider.logger.error("Could not create a Browserless human access URL.")
                    return False

                self._print_authorization_prompt(
                    spider,
                    url,
                    reason,
                    access_url,
                    live_timeout,
                    access_kind,
                    session_label,
                )

                try:
                    await asyncio.to_thread(
                        input,
                        "Press ENTER here after the browser verification/login is complete: ",
                    )
                except EOFError:
                    spider.logger.error(
                        "Cannot wait for human authorization because stdin is not interactive."
                    )
                    return False

                try:
                    await page.wait_for_load_state("domcontentloaded", timeout=10_000)
                except Exception:
                    pass

                Path(state_path).parent.mkdir(parents=True, exist_ok=True)
                await context.storage_state(path=paths.storage_state)
                session_state = await _collect_session_storage(context)
                _json_dump_atomic(paths.session_storage, session_state)
                context_meta = {
                    "saved_at": datetime.now(timezone.utc).isoformat(),
                    "authorized_url": page.url,
                    "trigger_url": url,
                    "trigger_reason": reason,
                    "context_kwargs": await _visible_page_context_kwargs(page, context_kwargs),
                }
                _json_dump_atomic(paths.context_meta, context_meta)

                spider.logger.info(
                    "Human authorization saved from %s: %s, %s, %s",
                    page.url,
                    paths.storage_state,
                    paths.session_storage,
                    paths.context_meta,
                )
                return True
        except Exception as exc:
            spider.logger.exception("Human authorization failed for %s: %s", url, exc)
            return False
        finally:
            if relay is not None:
                try:
                    await relay.stop()
                except Exception:
                    pass
            if context is not None:
                try:
                    await context.close()
                except Exception:
                    pass
            if browser is not None:
                try:
                    await browser.close()
                except Exception:
                    pass

    def _browserless_context_kwargs(self, state_path: str = "") -> dict[str, Any]:
        kwargs: dict[str, Any] = {
            "viewport": {
                "width": _coerce_int(self.settings.get("HUMAN_AUTH_VIEWPORT_WIDTH"), 1440),
                "height": _coerce_int(self.settings.get("HUMAN_AUTH_VIEWPORT_HEIGHT"), 900),
            },
            "locale": self.settings.get("HUMAN_AUTH_LOCALE", "en-US"),
            "timezone_id": self.settings.get("HUMAN_AUTH_TIMEZONE", "America/New_York"),
            "ignore_https_errors": True,
            "extra_http_headers": {"Accept-Language": "en-US,en;q=0.9"},
        }
        if state_path and os.path.exists(state_path):
            kwargs["storage_state"] = state_path
            apply_context_overrides(kwargs, state_path)
        return kwargs

    def _browserless_public_base(self) -> str:
        public_url = self.settings.get("BROWSERLESS_PUBLIC_URL", "")
        if public_url:
            return public_url.rstrip("/")
        return _http_base_from_ws_url(self.cdp_url)

    def _browserless_internal_base(self) -> str:
        return _http_base_from_ws_url(self.cdp_url)

    def _browserless_token(self) -> str:
        return _query_value(self.cdp_url, "token")

    async def _browser_access_url(self, cdp, session_label: str, live_timeout: int, spider) -> tuple[str, str]:
        try:
            live = await cdp.send(
                "Browserless.liveURL",
                {
                    "timeout": live_timeout,
                    "quality": _coerce_int(
                        self.settings.get("BROWSERLESS_LIVE_QUALITY"),
                        70,
                    ),
                    "type": self.settings.get("BROWSERLESS_LIVE_IMAGE_TYPE", "jpeg"),
                    "compressed": _coerce_bool(
                        self.settings.get("BROWSERLESS_LIVE_COMPRESSED"),
                        default=True,
                    ),
                },
            )
            live_url = live.get("liveURL") if isinstance(live, dict) else None
            if live_url:
                return live_url, "Browserless liveURL"
        except Exception as exc:
            if "Browserless.liveURL" not in str(exc) and "wasn't found" not in str(exc):
                spider.logger.warning("Browserless.liveURL failed; falling back to sessions: %s", exc)
            else:
                spider.logger.warning(
                    "Browserless.liveURL is not available on this Browserless instance; "
                    "falling back to /sessions debugger URL."
                )

        session_url = await self._session_debug_url(session_label, spider)
        if session_url:
            return session_url, "Browserless sessions/debugger fallback"
        return "", ""

    async def _session_debug_url(self, session_label: str, spider) -> str:
        token = self._browserless_token()
        public_base = self._browserless_public_base()
        internal_base = self._browserless_internal_base()
        internal_sessions_url = _with_query_params(
            f"{internal_base}/sessions",
            {"token": token},
        )
        public_sessions_url = _with_query_params(
            f"{public_base}/sessions",
            {"token": token},
        )
        try:
            sessions = await asyncio.to_thread(_http_get_json, internal_sessions_url)
        except (OSError, urllib.error.URLError, json.JSONDecodeError) as exc:
            spider.logger.warning(
                "Could not fetch Browserless sessions from %s: %s. "
                "Starting built-in relay fallback.",
                internal_sessions_url,
                exc,
            )
            return ""

        if not isinstance(sessions, list):
            spider.logger.warning(
                "Browserless /sessions returned %s instead of a list; "
                "starting built-in relay fallback.",
                type(sessions).__name__,
            )
            return ""

        selected = next((s for s in sessions if isinstance(s, dict)), None)

        if not selected:
            return ""

        for key in ("devtoolsFrontendUrl", "debuggerUrl", "inspectUrl"):
            value = selected.get(key)
            if value:
                return _normalize_browserless_url(value, public_base, token)
        spider.logger.warning(
            "Browserless /sessions had no debugger URL; starting built-in relay fallback."
        )
        return ""

    @staticmethod
    def _print_authorization_prompt(
        spider,
        url: str,
        reason: str,
        access_url: str,
        timeout_ms: int,
        access_kind: str,
        session_label: str,
    ) -> None:
        message = (
            "\n"
            "=" * 78
            + "\n"
            + "Human authorization required\n"
            + f"Blocked URL: {url}\n"
            + f"Reason: {reason}\n"
            + f"Browserless access type: {access_kind}\n"
            + f"Browserless session label: {session_label}\n"
            + f"Browserless access URL: {access_url}\n"
            + f"Live session timeout: {timeout_ms // 1000} seconds\n\n"
            + "Open the Browserless access URL, complete Cloudflare/institution login, "
            + "wait until the target page loads, then return to this terminal.\n"
            + "=" * 78
            + "\n"
        )
        print(message, flush=True)
        spider.logger.warning(
            "Human authorization required for %s (%s). Browserless access URL: %s",
            url,
            reason,
            access_url,
        )
