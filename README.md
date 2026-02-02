# Doubao Bridge

通过 scrcpy + AutoHotkey 将手机端豆包输入法的 AI/语音输入能力桥接到 Windows PC。

## 功能特性

- **Alt+Space**: 唤起 scrcpy 窗口并居中显示，自动打开输入容器 App
- **Ctrl+Enter**: 一键上屏，将手机输入内容粘贴到 PC 当前应用
- **专用 Android App**: 全屏输入框 + 快捷短语面板

## 系统要求

- Windows 10/11
- Android 手机（已开启 USB 调试）
- [scrcpy](https://github.com/Genymobile/scrcpy) v3.x

## 快速开始

### 1. 下载依赖工具

由于体积较大，以下工具不包含在仓库中，需手动下载到 `tools/` 目录：

| 工具 | 下载地址 | 放置路径 |
|------|----------|----------|
| ADB | 从 scrcpy 复制 `adb.exe`, `AdbWinApi.dll`, `AdbWinUsbApi.dll` | `tools/adb/` |
| JDK 17 | [Eclipse Temurin 17](https://adoptium.net/temurin/releases/?version=17) (zip) | `tools/jdk/jdk-17.x.x+xx/` |
| Android SDK | 运行 `scripts/setup-android-sdk.bat` 自动下载 | `tools/android-sdk/` |
| AutoHotkey v2 | [AutoHotkey v2.0](https://www.autohotkey.com/) (portable zip) | `tools/ahk/` |

### 2. 构建 Android App

```batch
scripts\build-android.bat
```

### 3. 安装到手机

```batch
scripts\install-android.bat
```

或手动安装：APK 位于 `src\android\app\build\outputs\apk\debug\app-debug.apk`

### 4. 启动

```batch
scripts\start-all.bat
```

## 使用方法

1. 连接手机，运行 `scripts\start-all.bat`
2. 在 PC 任意应用中按 **Alt+Space** 唤起输入
3. 在手机上使用豆包输入法输入内容
4. 按 **Ctrl+Enter** 或点击「上屏」按钮，内容自动粘贴到 PC

## 项目结构

```
Doubao_win/
├── docs/                  # 需求文档
├── scripts/               # 启动/构建脚本
│   ├── start-all.bat      # 一键启动
│   ├── stop-all.bat       # 一键停止
│   ├── build-android.bat  # 构建 APK
│   └── install-android.bat# 安装 APK
├── src/
│   ├── ahk/               # AutoHotkey 脚本
│   │   └── doubao-bridge.ahk
│   └── android/           # Android App 源码
├── tools/                 # 工具目录 (gitignore)
│   ├── adb/
│   ├── ahk/
│   ├── jdk/
│   └── android-sdk/
└── README.md
```

## 技术栈

- **Windows**: AutoHotkey v2.0
- **Android**: Kotlin + Gradle
- **桥接**: scrcpy (屏幕镜像 + 剪贴板同步)

## License

MIT
