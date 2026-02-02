# Doubao Bridge 豆包输入桥

[English](./README_EN.md) | 简体中文

通过 scrcpy + AutoHotkey 将手机端**豆包输入法**的 AI/语音输入能力桥接到 Windows PC。

## 功能特性

- **Alt+Space**: 唤起 scrcpy 窗口并居中显示，自动打开输入容器 App
- **Ctrl+Enter**: 一键上屏，将手机输入内容粘贴到 PC 当前应用
- **专用 Android App**: 全屏输入框 + 上屏按钮 + 快捷短语面板

## 工作原理

```
┌─────────────┐     剪贴板同步      ┌─────────────┐
│  Windows PC │◄──────────────────►│  Android 手机│
│             │      (scrcpy)       │             │
│  Alt+Space  │────────────────────►│  打开 App   │
│             │                     │  豆包输入法  │
│  Ctrl+Enter │◄────────────────────│  点击上屏   │
│  自动粘贴   │     剪贴板内容       │             │
└─────────────┘                     └─────────────┘
```

## 系统要求

- **操作系统**: Windows 10/11 (64-bit)
- **Android 手机**: Android 7.0+ (API 26+)，已开启 USB 调试
- **USB 数据线**: 用于连接手机和电脑

## 快速开始

### 第一步：克隆仓库

```bash
git clone https://github.com/你的用户名/Doubao-Bridge.git
cd Doubao-Bridge
```

### 第二步：下载依赖工具

由于体积较大（约 500MB），以下工具不包含在仓库中，需手动下载：

#### 2.1 下载 scrcpy

1. 前往 [scrcpy Releases](https://github.com/Genymobile/scrcpy/releases)
2. 下载 `scrcpy-win64-v3.x.zip`
3. 解压到任意目录（如 `C:\scrcpy`）
4. 修改 `scripts\start-scrcpy.bat` 中的路径：
   ```batch
   cd /d "C:\你的scrcpy路径"
   ```

#### 2.2 部署 ADB

从 scrcpy 目录复制以下文件到 `tools\adb\`：
- `adb.exe`
- `AdbWinApi.dll`
- `AdbWinUsbApi.dll`

#### 2.3 下载 AutoHotkey v2

1. 前往 [AutoHotkey v2 下载页](https://www.autohotkey.com/download/)
2. 下载 **Portable** 版本（zip）
3. 解压到 `tools\ahk\`，确保存在 `tools\ahk\AutoHotkey64.exe`

#### 2.4 下载 JDK 17（构建 Android App 需要）

1. 前往 [Eclipse Temurin 下载页](https://adoptium.net/temurin/releases/?version=17)
2. 选择 **Windows x64** + **JDK** + **zip**
3. 下载并解压到 `tools\jdk\`
4. 确保路径格式为 `tools\jdk\jdk-17.x.x+xx\bin\java.exe`

#### 2.5 安装 Android SDK

运行以下脚本自动下载和配置：

```batch
scripts\setup-android-sdk.bat
```

> 此脚本会下载 cmdline-tools、platforms;android-34、build-tools;34.0.0（约 200MB）

### 第三步：配置 scrcpy 窗口标题

1. 连接手机，运行 scrcpy 查看窗口标题（通常是设备序列号）
2. 编辑 `src\ahk\doubao-bridge.ahk`，修改第 5 行：
   ```autohotkey
   static SCRCPY_TITLE := "你的设备序列号"
   ```

### 第四步：构建 Android App

```batch
scripts\build-android.bat
```

首次构建需要下载 Gradle 和依赖，可能需要 3-5 分钟。

### 第五步：安装到手机

**方法 A：ADB 安装**（需开启「USB 安装」权限）

```batch
scripts\install-android.bat
```

**方法 B：手动安装**

APK 位于：`src\android\app\build\outputs\apk\debug\app-debug.apk`

复制到手机后手动安装。

### 第六步：启动

```batch
scripts\start-all.bat
```

## 使用方法

1. 连接手机，运行 `scripts\start-all.bat`
2. 在 PC 任意应用（如微信、Word）中按 **Alt+Space** 唤起输入
3. 在手机上使用**豆包输入法**输入内容（支持语音、AI 对话等）
4. 输入完成后：
   - 按 **Ctrl+Enter**，内容自动粘贴到 PC 光标位置
   - 或点击 App 中的「上屏」按钮，然后手动 Ctrl+V

## 目录结构

```
Doubao-Bridge/
├── docs/                      # 需求文档和设计文档
├── scripts/                   # 启动/构建脚本
│   ├── start-all.bat          # 一键启动 (scrcpy + AHK)
│   ├── stop-all.bat           # 一键停止
│   ├── start-scrcpy.bat       # 启动 scrcpy
│   ├── start-ahk.bat          # 启动 AHK 脚本
│   ├── build-android.bat      # 构建 APK
│   ├── install-android.bat    # 安装 APK
│   └── setup-android-sdk.bat  # 初始化 Android SDK
├── src/
│   ├── ahk/
│   │   └── doubao-bridge.ahk  # AutoHotkey 热键脚本
│   └── android/               # Android App 源码
│       └── app/src/main/
│           ├── kotlin/        # Kotlin 代码
│           └── res/           # 资源文件
├── tools/                     # 工具目录 (需手动下载，不在 Git 中)
│   ├── adb/                   # ADB 工具
│   ├── ahk/                   # AutoHotkey v2
│   ├── jdk/                   # JDK 17
│   └── android-sdk/           # Android SDK
├── logs/                      # 日志目录
├── .gitignore
└── README.md
```

## 常见问题

### Q: scrcpy 启动失败？

确保：
1. 手机已开启 **USB 调试**
2. 已授权电脑的 ADB 调试
3. USB 线支持数据传输（非纯充电线）

### Q: APK 安装失败 (INSTALL_FAILED_USER_RESTRICTED)？

小米/MIUI 手机需要额外开启：
- **设置 → 更多设置 → 开发者选项 → USB 安装**
- 可能需要登录小米账号

### Q: Alt+Space 没反应？

1. 确认 AHK 脚本正在运行（任务栏有绿色 H 图标）
2. 确认 scrcpy 窗口标题与配置一致
3. 检查 `logs\doubao-bridge.log` 日志

### Q: 剪贴板没有同步？

确保 scrcpy 启动时没有加 `--no-clipboard-autosync` 参数。

## 技术栈

| 组件 | 技术 |
|------|------|
| Windows 热键 | AutoHotkey v2.0 |
| Android App | Kotlin + Gradle |
| 屏幕镜像 | scrcpy 3.x |
| 剪贴板同步 | scrcpy 内置功能 (ADB) |

## 许可证

MIT License

## 致谢

- [scrcpy](https://github.com/Genymobile/scrcpy) - 强大的 Android 屏幕镜像工具
- [AutoHotkey](https://www.autohotkey.com/) - Windows 自动化脚本语言
- [豆包](https://www.doubao.com/) - 字节跳动 AI 输入法
