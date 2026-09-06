# YAOpenEvidence Flutter 客户端

面向 Android / Linux / Windows 的原生客户端，与 `frontend/`（浏览器）和 `apple/`（iPhone / iPad / Mac）功能对等：登录、提问与筛选、答案页实时流水线进度（SSE）+ 段落级引用 + 原文阅读器、问答历史、文献库与文献详情、知识库检索与重建、上游文献检索与全文预览、账号设置、管理员用户管理。

后端协议见仓库根的 [docs/api.md](../docs/api.md)。

## 工具链

| 项 | 版本 / 说明 |
|---|---|
| Flutter | `3.47.2` stable（Dart 3.13.2），由 `.fvmrc` 固定；命令一律 `fvm flutter …` / `fvm dart …` |
| 平台 | `android`、`linux`、`windows`（iOS/macOS 归 `apple/`，Web 归 `frontend/`） |
| Linux 桌面构建 | `clang`、`cmake`、`ninja`、`pkg-config`、`gtk3`、`libsecret` |
| Android 构建 | Android SDK（platform 37 + build-tools 36 起）+ JDK 17；`android/app/build.gradle.kts` 固定 `compileSdk = 37`（插件 AAR 已按 37 发布，模板默认 36 会在 `checkDebugAarMetadata` 失败） |

```bash
cd flutter
fvm install                                    # 按 .fvmrc 安装固定版本
fvm flutter config --android-sdk /opt/android-sdk \
                   --jdk-dir /usr/lib/jvm/java-17-openjdk
fvm flutter pub get
```

Gradle 不支持较新的系统默认 JDK，因此必须显式指向 JDK 17；`flutter doctor -v` 里 Android toolchain 和 Linux toolchain 都应为绿色。

## 字体

标题使用裁剪后的 Noto Serif SC，正文数字与拉丁字符使用 Inter，中文正文走系统无衬线回退。产物已入库（`assets/fonts/`），运行时不请求任何第三方 CDN。需要更新字体时执行：

```bash
tool/fetch_fonts.sh    # 需要 curl、unzip、uvx（fonttools）
```

脚本会下载 Noto Serif SC 可变字体并用 `pyftsubset` 裁到「拉丁 + 标点 + CJK 基本区 + 全宽符号」（保留 `wght` 轴），再从 Inter 发布包取 `InterVariable.ttf`，同时写入 `assets/fonts/OFL.txt`。

## 代码生成

模型（freezed + json_serializable）与 provider（riverpod_generator）依赖生成代码，`*.g.dart` / `*.freezed.dart` **入库**（与 `frontend/src/api/schema.d.ts` 的策略一致）：

```bash
fvm dart run build_runner build      # 一次性生成
fvm dart run build_runner watch      # 开发期监听
```

`build_runner` 2.16 已移除 `--delete-conflicting-outputs`，不要再传。JSON 字段映射统一在 `build.yaml` 配置（`field_rename: snake`、`include_if_null: false`），模型里不再逐个标注。

## 检查与测试

```bash
fvm flutter analyze                  # 0 issues（含 riverpod_lint 原生 analyzer 插件）
fvm flutter test                     # 单元测试
```

`analysis_options.yaml` 用 Dart 3.9+ 的新插件系统在顶层 `plugins:` 声明 `riverpod_lint`（旧的 `analyzer.plugins:` 列表写法已废弃），插件 lint 需逐条在 `diagnostics:` 里开启。

测试集中在纯逻辑与协议边界：

- `test/core/api/`：SSE 解析状态机、查询串编码、Problem 错误映射、401 会话失效、事件流请求头。
- `test/core/logic/`：筛选归一化与请求体、引用标记与色板、任务事件归约、Markdown 解析、引文高亮。
- `test/core/models/`：线上字段映射（snake_case、未知枚举回落、null 省略）。
- `test/core/session/`：服务器地址校验（明文 http 仅限本地网络）。
- `test/features/answer/`：SSE 断线重连退避与探活（`fake_async`）。

用例集与 `apple/YAOEKit/Tests/` 同源，改动纯逻辑时两边应同步。

## 构建

```bash
fvm flutter build linux --release
ANDROID_HOME=/opt/android-sdk fvm flutter build apk --debug
```

APK 产物在 `build/app/outputs/flutter-apk/`。Windows 目录随 `flutter create` 入库，但只能在 Windows 主机上构建（本仓库的 CI/开发机为 Linux）。

## 端到端冒烟

`integration_test/e2e_smoke_test.dart` 需要一套可用的后端，通过 `--dart-define` 提供凭据后才会执行，否则整体跳过：

```bash
fvm flutter test integration_test/e2e_smoke_test.dart -d linux \
  --dart-define=YAOE_E2E_API=http://127.0.0.1:18766 \
  --dart-define=YAOE_E2E_USER=admin \
  --dart-define=YAOE_E2E_PASSWORD=***
```

流程：登录 → 提问（`papers=1`，关闭知识库）→ 等待终态（≤ 10 分钟）→ 断言正文出现引用芯片 → 点击芯片 → 断言阅读器显示带高亮的段落。

## 目录结构

```text
lib/
  main.dart                  # 读偏好 → ProviderScope（4xx 不自动重试）→ App
  app/                       # MaterialApp.router、主题令牌与 ThemeData、路由、答案版本号
  core/api/                  # ApiClient（REST + SSE）、错误映射、查询串编码、端点封装
  core/models/               # freezed 数据类，对齐 /v1 契约
  core/logic/                # 纯逻辑：筛选、引用、任务事件归约、Markdown、引文高亮
  core/session/              # 偏好、令牌存储、地址校验、会话状态机
  features/<page>/           # 按页面分包：ask / answer / reader / history / library / kb / literature / account / admin / shell / login
  shared/                    # 跨页组件、外链、格式化
test/                        # 与 lib 同构的单元测试
integration_test/            # 端到端冒烟
```

## 平台行为差异

- 令牌存储：Android 走 EncryptedSharedPreferences，Linux 依赖桌面会话的 Secret Service（libsecret），Windows 用 DPAPI。Linux 上先看 `DBUS_SESSION_BUS_ADDRESS` / `SECRET_SERVICE_ADDRESS`：没有可用会话（CI、容器、Xvfb）时直接走明文偏好——libsecret 此时只发 GLib 警告，插件转不成 Dart 异常，硬写会终止进程。回退状态在账号页显示「当前平台无安全存储，令牌以明文保存」，不阻塞登录。
- 明文 `http://` 只允许 localhost、`.local`/`.localhost`、`::1` 与私有网段；公网地址必须 `https://`。
- 动效只用框架内置能力，并尊重系统「减弱动效」设置。
