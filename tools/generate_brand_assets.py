"""从已确认的 SVG 母版生成各客户端品牌资源。依赖 Python 标准库与 rsvg-convert。"""

import shutil
import struct
import subprocess
import xml.etree.ElementTree as ET
from copy import deepcopy
from functools import lru_cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)
DARK = {"#17616B": "#8AD7DE", "#279C87": "#64D8B5", "#FFFFFF": "#153D43"}
TINTED = {"#17616B": "#E7E7E7", "#279C87": "#FFFFFF", "#FFFFFF": "#2C2C2C"}
LIGHT_BACKGROUND = "#F7FAF9"
DARK_BACKGROUND = "#182C30"


def svg_bytes(root: ET.Element) -> bytes:
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)


def recolor(source: ET.Element, palette: dict[str, str]) -> ET.Element:
    root = deepcopy(source)
    for element in root.iter():
        for attribute in ("fill", "stroke"):
            value = element.get(attribute)
            if value in palette:
                element.set(attribute, palette[value])
    return root


def icon_svg(source: ET.Element, background: str, rounded: bool = False) -> bytes:
    root = deepcopy(source)
    bounds = (
        {"x": "8", "y": "8", "width": "240", "height": "240", "rx": "52"}
        if rounded
        else {"width": "256", "height": "256"}
    )
    root.insert(0, ET.Element(f"{{{NS}}}rect", {**bounds, "fill": background}))
    return svg_bytes(root)


def padded_svg(source: ET.Element) -> bytes:
    # Android 自适应图标的可见图形位于中央安全区，留出系统裁切与动画空间。
    root = deepcopy(source)
    root.set("viewBox", "-64 -64 384 384")
    return svg_bytes(root)


def adaptive_svg(source: ET.Element) -> bytes:
    variables = {
        "#17616B": "var(--book)",
        "#279C87": "var(--check)",
        "#FFFFFF": "var(--ink)",
    }
    root = recolor(source, variables)
    style = ET.Element(f"{{{NS}}}style")
    style.text = (
        ":root{--book:#17616B;--check:#279C87;--ink:#FFFFFF}"
        "@media(prefers-color-scheme:dark){:root{--book:#8AD7DE;--check:#64D8B5;--ink:#153D43}}"
    )
    root.insert(0, style)
    return svg_bytes(root)


def android_monochrome() -> bytes:
    android = "http://schemas.android.com/apk/res/android"
    ET.register_namespace("android", android)
    root = ET.Element(
        "vector",
        {
            f"{{{android}}}width": "108dp",
            f"{{{android}}}height": "108dp",
            f"{{{android}}}viewportWidth": "384",
            f"{{{android}}}viewportHeight": "384",
        },
    )
    group = ET.SubElement(
        root,
        "group",
        {
            f"{{{android}}}translateX": "64",
            f"{{{android}}}translateY": "64",
        },
    )
    mono = ET.parse(ROOT / "docs/assets/logo-mono.svg").getroot()
    for source in mono.findall(f"{{{NS}}}path"):
        path = ET.SubElement(
            group, "path", {f"{{{android}}}pathData": source.attrib["d"]}
        )
        for name in ("fill", "stroke"):
            if source.get(name) == "currentColor":
                path.set(f"{{{android}}}{name}Color", "#FFFFFFFF")
        for source_key, target_key in [
            ("stroke-width", "strokeWidth"),
            ("stroke-linecap", "strokeLineCap"),
            ("stroke-linejoin", "strokeLineJoin"),
        ]:
            if value := source.get(source_key):
                path.set(f"{{{android}}}{target_key}", value)
        if source.get("fill-rule") == "evenodd":
            path.set(f"{{{android}}}fillType", "evenOdd")
    return svg_bytes(root)


def save_bytes(relative: str, content: bytes) -> None:
    path = ROOT / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    _ = path.write_bytes(content)


@lru_cache(maxsize=48)
def rasterize(source: bytes, size: int) -> bytes:
    result = subprocess.run(
        ["rsvg-convert", "--width", str(size), "--height", str(size)],
        input=source,
        capture_output=True,
        check=True,
    )
    return result.stdout


def save_png(relative: str, source: bytes, size: int, opaque: bool = False) -> None:
    image = rasterize(source, size)
    # PNG 的 IHDR 色彩类型 2 为无 alpha 的 RGB，满足 iOS 图标要求。
    if opaque and image[25] != 2:
        raise ValueError(f"应用图标不是不透明 RGB：{relative}")
    save_bytes(relative, image)


def save_ico(relative: str, source: bytes, sizes: list[int]) -> None:
    # ICO 目录指向各尺寸的 PNG，现代 Windows 与浏览器均原生支持。
    images = [rasterize(source, size) for size in sizes]
    header = struct.pack("<HHH", 0, 1, len(sizes))
    offset = len(header) + 16 * len(sizes)
    entries = []
    for size, image in zip(sizes, images, strict=True):
        entries.append(
            struct.pack(
                "<BBBBHHII", size % 256, size % 256, 0, 0, 1, 32, len(image), offset
            )
        )
        offset += len(image)
    save_bytes(relative, header + b"".join(entries) + b"".join(images))


def main() -> None:
    if not shutil.which("rsvg-convert"):
        raise SystemExit("缺少 rsvg-convert，请先安装 librsvg。")
    source = ET.parse(ROOT / "docs/assets/logo.svg").getroot()
    dark = recolor(source, DARK)
    light_svg, dark_svg = svg_bytes(source), svg_bytes(dark)
    light_icon = icon_svg(source, LIGHT_BACKGROUND)
    dark_icon = icon_svg(dark, DARK_BACKGROUND)
    desktop_icon = icon_svg(source, LIGHT_BACKGROUND, rounded=True)
    save_bytes("docs/assets/logo-dark.svg", dark_svg)

    web = "frontend/public/brand"
    save_bytes(f"{web}/logo-light.svg", light_svg)
    save_bytes(f"{web}/logo-dark.svg", dark_svg)
    save_bytes(f"{web}/favicon.svg", adaptive_svg(source))
    save_ico(f"{web}/favicon.ico", light_svg, [16, 32, 48])
    for name, size in [("apple-touch-icon", 180), ("icon-192", 192), ("icon-512", 512)]:
        save_png(f"{web}/{name}.png", light_icon, size, opaque=True)

    apple = "apple/YAOpenEvidence/Resources/Assets.xcassets"
    for name, svg in [("light", light_svg), ("dark", dark_svg)]:
        for suffix, size in [("", 256), ("@2x", 512), ("@3x", 768)]:
            save_png(f"{apple}/BrandLogo.imageset/logo-{name}{suffix}.png", svg, size)
    for name, svg in [
        ("light", light_icon),
        ("dark", dark_icon),
        ("tinted", icon_svg(recolor(source, TINTED), "#202020")),
    ]:
        save_png(f"{apple}/AppIcon.appiconset/ios-{name}.png", svg, 1024, opaque=True)
    for size in [16, 32, 64, 128, 256, 512, 1024]:
        save_png(f"{apple}/AppIcon.appiconset/mac-{size}.png", desktop_icon, size)

    flutter = "flutter/assets/brand"
    for name, svg in [("light", light_svg), ("dark", dark_svg)]:
        for directory, size in [("", 256), ("2.0x/", 512), ("3.0x/", 768)]:
            save_png(f"{flutter}/{directory}logo-{name}.png", svg, size)
    save_png(f"{flutter}/app-icon.png", desktop_icon, 512)
    save_ico(
        "flutter/windows/runner/resources/app_icon.ico",
        desktop_icon,
        [16, 24, 32, 48, 64, 128, 256],
    )

    android = "flutter/android/app/src/main/res"
    save_bytes(f"{android}/drawable/ic_launcher_monochrome.xml", android_monochrome())
    for density, launcher_size, adaptive_size in [
        ("mdpi", 48, 108),
        ("hdpi", 72, 162),
        ("xhdpi", 96, 216),
        ("xxhdpi", 144, 324),
        ("xxxhdpi", 192, 432),
    ]:
        save_png(
            f"{android}/mipmap-{density}/ic_launcher.png",
            light_icon,
            launcher_size,
            opaque=True,
        )
        for suffix, svg in [("", source), ("_dark", dark)]:
            foreground = padded_svg(svg)
            for name in ["ic_launcher_foreground", "brand_splash"]:
                save_png(
                    f"{android}/drawable-{density}/{name}{suffix}.png",
                    foreground,
                    adaptive_size,
                )
    print(
        "已从 docs/assets/logo.svg 生成 Web、Apple、Flutter/Android/Windows 品牌资源。"
    )


if __name__ == "__main__":
    main()
