# Doubao Bridge 豆包输入桥

[English](./README_EN.md) | 简体中文

通过 scrcpy + AutoHotkey 将手机端**豆包输入法**的 AI/语音输入能力桥接到 Windows PC。支持 USB 有线和 **Wi-Fi 无线**两种投屏模式。

## 功能特性

- **鼠标中键**: 智能识别 - 呼出投屏窗口 / 一键上屏
- **Wi-Fi 无线投屏**: 通过局域网无线连接，摆脱数据线束缚
- **投屏窗口置顶**: 输入时不会被其他窗口遮挡
- **专用 Android App**: 全屏输入框 + 快捷短语面板
- **便携版设计**: 所有工具集成在项目文件夹内

## 工作原理

```
┌─────────────────────────────────────────────────────────┐
│  鼠标中键 智能判断：                                      │
│                                                         │
│  投屏窗口最小化 → 按中键 → 呼出窗口（置顶显示）           │
│                                                         │
│  投屏窗口已显示 → 按中键 → 复制内容 → 粘贴到 PC          │
│                          → 清空记事本 → 窗口保持显示     │
└─────────────────────────────────────────────────────────┘
```

## 系统要求

- **操作系统**: Windows 10/11 (64-bit)
- **Android 手机**: Android 7.0+ (API 26+)，已开启 USB 调试
- **USB 数据线**: 首次配置时需要，Wi-Fi 模式日常使用无需
- **局域网**: USB 模式无需，Wi-Fi 模式需手机和电脑在同一局域网

## 快速开始

### 第一步：克隆仓库

```bash
git clone https://github.com/qzy03715/Doubao-Bridge.git
cd Doubao-Bridge
```

### 第二步：下载依赖工具

由于体积较大（约 600MB），以下工具不包含在仓库中，需手动下载到 `tools/` 目录：

#### 2.1 下载 scrcpy（必需）

1. 前往 [scrcpy Releases](https://github.com/Genymobile/scrcpy/releases)
2. 下载 `scrcpy-win64-v3.x.zip`
3. **解压到 `tools\scrcpy\`**，确保存在 `tools\scrcpy\scrcpy.exe`

#### 2.2 下载 AutoHotkey v2（必需）

1. 前往 [AutoHotkey v2 下载页](https://www.autohotkey.com/download/)
2. 下载 **Portable** 版本（zip）
3. 解压到 `tools\ahk\`，确保存在 `tools\ahk\AutoHotkey64.exe`

#### 2.3 部署 ADB（必需）

从 `tools\scrcpy\` 复制以下文件到 `tools\adb\`：
- `adb.exe`
- `AdbWinApi.dll`
- `AdbWinUsbApi.dll`

#### 2.4 下载 JDK 17（仅构建 App 需要）

1. 前往 [Eclipse Temurin 下载页](https://adoptium.net/temurin/releases/?version=17)
2. 选择 **Windows x64** + **JDK** + **zip**
3. 下载并解压到 `tools\jdk\`
4. 确保路径格式为 `tools\jdk\jdk-17.x.x+xx\bin\java.exe`

#### 2.5 安装 Android SDK（仅构建 App 需要）

```batch
scripts\setup-android-sdk.bat
```

### 第三步：配置设备标识

1. 用 USB 连接手机，运行 scrcpy 查看窗口标题（通常是设备型号，如 `2505APX7BC`）
2. 编辑 `src\ahk\config.json`，修改 `device.scrcpyTitle`：
   ```json
   "device": {
     "scrcpyTitle": "你的设备型号"
   }
   ```

### 第四步：构建 Android App（可选）

```batch
scripts\build-android.bat
scripts\install-android.bat
```

或手动安装预编译的 APK（如有提供）。

### 第五步：启动

**USB 有线模式：**

```batch
scripts\start-all.bat
```

**Wi-Fi 无线模式（推荐）：**

```batch
:: 首次：USB 连接手机，运行一次开启无线模式（自动获取 IP 并写入配置）
scripts\enable-wifi-mode.bat

:: 日常：拔掉 USB，直接启动
scripts\start-wifi.bat
```

> 注意：手机重启后需重新运行 `enable-wifi-mode.bat`

## 使用方法

1. 运行 `scripts\start-wifi.bat`（或 `start-all.bat`）
2. **按鼠标中键** → 呼出投屏窗口（置顶显示）
3. 在手机上使用**豆包输入法**输入内容
4. 在 PC 上**点击目标位置**（如微信输入框）
5. **按鼠标中键** → 内容自动粘贴，记事本清空
6. 继续输入下一段，重复 4-5 步

## 配置文件

配置文件位于 `src\ahk\config.json`：

```json
{
  "hotkey": {
    "trigger": "MButton",       // 触发键：MButton/XButton1/XButton2/Alt+Space
    "cancel": "Escape"
  },
  "device": {
    "scrcpyTitle": "设备型号",   // scrcpy 窗口标题（设备型号名）
    "ip": "192.168.0.87"        // 手机局域网 IP（Wi-Fi 模式，空值为 USB 模式）
  },
  "path": {
    "scrcpy": "tools\\scrcpy"   // scrcpy 路径（相对于项目根目录）
  }
}
```

### 支持的快捷键

| 配置值 | 说明 |
|--------|------|
| `MButton` | 鼠标中键 |
| `XButton1` | 鼠标侧键 1 |
| `XButton2` | 鼠标侧键 2 |
| `Alt+Space` | Alt + 空格 |
| `Ctrl+Space` | Ctrl + 空格 |

## 目录结构

```
Doubao-Bridge/
├── docs/                          # 文档
├── scripts/                       # 启动/构建脚本
│   ├── start-all.bat              # 一键启动（USB）
│   ├── start-wifi.bat             # 一键启动（Wi-Fi）
│   ├── stop-all.bat               # 一键关闭
│   ├── enable-wifi-mode.bat       # 开启 Wi-Fi 无线模式
│   ├── update-wifi-config.ps1     # Wi-Fi 配置更新辅助脚本
│   ├── build-android.bat          # 构建 APK
│   └── install-android.bat        # 安装 APK
├── src/
│   ├── ahk/
│   │   ├── doubao-bridge.ahk      # AHK 主脚本
│   │   ├── config.json            # 配置文件
│   │   └── lib/                   # AHK 库
│   └── android/                   # Android App 源码
├── tools/                         # 工具目录（需手动下载）
│   ├── scrcpy/                    # scrcpy 投屏工具
│   ├── adb/                       # ADB 工具
│   ├── ahk/                       # AutoHotkey v2
│   ├── jdk/                       # JDK 17（构建用）
│   └── android-sdk/               # Android SDK（构建用）
└── logs/                          # 运行日志
```

## 常见问题

### Q: 鼠标中键没反应？

1. 确认 AHK 脚本正在运行（任务栏有绿色 H 图标）
2. 检查 `config.json` 中的 `scrcpyTitle` 是否与 scrcpy 窗口标题一致

### Q: Wi-Fi 模式连接失败？

1. 确认手机和电脑在同一局域网（连接同一路由器/CPE）
2. 确认 `enable-wifi-mode.bat` 已运行成功
3. 手机重启后需重新运行 `enable-wifi-mode.bat`（需 USB）

### Q: Wi-Fi 投屏会消耗手机流量吗？

不会。scrcpy 和 adb 的通信是纯局域网流量，数据只在手机和电脑之间通过路由器内网传输，不经过互联网。

### Q: scrcpy 快捷键不工作？

scrcpy 使用 `RAlt` 作为快捷键修饰符：
- `RAlt + H` - 返回主屏幕
- `RAlt + B` - 返回
- `RAlt + S` - 切换 App

### Q: 投屏有黑边？

检查是否手动调整过窗口大小，重启 scrcpy 即可恢复。

## 技术栈

| 组件 | 技术 |
|------|------|
| Windows 热键 | AutoHotkey v2.0 |
| Android App | Kotlin + Gradle |
| 屏幕镜像 | scrcpy 3.x |
| 剪贴板同步 | scrcpy 内置 (ADB) + ClipWait 自适应 |
| 连接方式 | USB / Wi-Fi (adb tcpip) |

## 许可证

MIT License

## 致谢

- [scrcpy](https://github.com/Genymobile/scrcpy) - Android 屏幕镜像工具
- [AutoHotkey](https://www.autohotkey.com/) - Windows 自动化脚本
- [豆包](https://www.doubao.com/) - 字节跳动 AI 输入法
