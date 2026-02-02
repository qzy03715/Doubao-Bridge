# Doubao Bridge

[简体中文](./README.md) | English

Bridge the AI/voice input capabilities of the mobile **Doubao Input Method** to Windows PC via scrcpy + AutoHotkey.

## Features

- **Alt+Space**: Bring up the scrcpy window centered on screen, auto-launch the input container App
- **Ctrl+Enter**: One-click send — paste phone input content into the current PC application
- **Dedicated Android App**: Full-screen input field + send button + quick phrases panel

## How It Works

```
┌─────────────┐   Clipboard Sync    ┌─────────────┐
│  Windows PC │◄────────────────────►│Android Phone│
│             │      (scrcpy)        │             │
│  Alt+Space  │─────────────────────►│  Open App   │
│             │                      │  Doubao IME │
│  Ctrl+Enter │◄─────────────────────│  Tap Send   │
│  Auto-paste │    Clipboard data    │             │
└─────────────┘                      └─────────────┘
```

## Requirements

- **OS**: Windows 10/11 (64-bit)
- **Android Phone**: Android 7.0+ (API 26+) with USB Debugging enabled
- **USB Cable**: For connecting phone to PC

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/Doubao-Bridge.git
cd Doubao-Bridge
```

### Step 2: Download Dependencies

The following tools are not included in the repository due to their size (~500MB). Download them manually:

#### 2.1 Download scrcpy

1. Go to [scrcpy Releases](https://github.com/Genymobile/scrcpy/releases)
2. Download `scrcpy-win64-v3.x.zip`
3. Extract to any directory (e.g., `C:\scrcpy`)
4. Update the path in `scripts\start-scrcpy.bat`:
   ```batch
   cd /d "C:\your-scrcpy-path"
   ```

#### 2.2 Deploy ADB

Copy the following files from the scrcpy directory to `tools\adb\`:
- `adb.exe`
- `AdbWinApi.dll`
- `AdbWinUsbApi.dll`

#### 2.3 Download AutoHotkey v2

1. Go to [AutoHotkey v2 Downloads](https://www.autohotkey.com/download/)
2. Download the **Portable** version (zip)
3. Extract to `tools\ahk\`, ensuring `tools\ahk\AutoHotkey64.exe` exists

#### 2.4 Download JDK 17 (Required for building the Android App)

1. Go to [Eclipse Temurin Downloads](https://adoptium.net/temurin/releases/?version=17)
2. Select **Windows x64** + **JDK** + **zip**
3. Download and extract to `tools\jdk\`
4. Ensure the path format is `tools\jdk\jdk-17.x.x+xx\bin\java.exe`

#### 2.5 Install Android SDK

Run the following script to automatically download and configure:

```batch
scripts\setup-android-sdk.bat
```

> This script downloads cmdline-tools, platforms;android-34, and build-tools;34.0.0 (~200MB)

### Step 3: Configure scrcpy Window Title

1. Connect your phone and run scrcpy to check the window title (usually the device serial number)
2. Edit `src\ahk\doubao-bridge.ahk`, modify line 5:
   ```autohotkey
   static SCRCPY_TITLE := "your-device-serial"
   ```

### Step 4: Build the Android App

```batch
scripts\build-android.bat
```

The first build downloads Gradle and dependencies, which may take 3-5 minutes.

### Step 5: Install to Phone

**Method A: ADB Install** (requires "USB Install" permission enabled)

```batch
scripts\install-android.bat
```

**Method B: Manual Install**

The APK is located at: `src\android\app\build\outputs\apk\debug\app-debug.apk`

Copy it to your phone and install manually.

### Step 6: Launch

```batch
scripts\start-all.bat
```

## Usage

1. Connect your phone and run `scripts\start-all.bat`
2. In any PC application (e.g., WeChat, Word), press **Alt+Space** to activate input
3. Use **Doubao Input Method** on your phone (supports voice, AI chat, etc.)
4. When done:
   - Press **Ctrl+Enter** to auto-paste content at the PC cursor position
   - Or tap the "Send" button in the App, then manually Ctrl+V on PC

## Project Structure

```
Doubao-Bridge/
├── docs/                      # Requirements & design docs
├── scripts/                   # Launch/build scripts
│   ├── start-all.bat          # One-click start (scrcpy + AHK)
│   ├── stop-all.bat           # One-click stop
│   ├── start-scrcpy.bat       # Start scrcpy
│   ├── start-ahk.bat          # Start AHK script
│   ├── build-android.bat      # Build APK
│   ├── install-android.bat    # Install APK
│   └── setup-android-sdk.bat  # Initialize Android SDK
├── src/
│   ├── ahk/
│   │   └── doubao-bridge.ahk  # AutoHotkey hotkey script
│   └── android/               # Android App source code
│       └── app/src/main/
│           ├── kotlin/        # Kotlin code
│           └── res/           # Resource files
├── tools/                     # Tools directory (download manually, not in Git)
│   ├── adb/                   # ADB tools
│   ├── ahk/                   # AutoHotkey v2
│   ├── jdk/                   # JDK 17
│   └── android-sdk/           # Android SDK
├── logs/                      # Log directory
├── .gitignore
└── README.md
```

## FAQ

### Q: scrcpy won't start?

Ensure:
1. **USB Debugging** is enabled on your phone
2. You've authorized ADB debugging on the computer
3. Your USB cable supports data transfer (not charge-only)

### Q: APK install fails with INSTALL_FAILED_USER_RESTRICTED?

Xiaomi/MIUI phones require an additional setting:
- **Settings → Additional Settings → Developer Options → Install via USB**
- May require signing in with a Xiaomi account

### Q: Alt+Space doesn't respond?

1. Confirm the AHK script is running (green H icon in taskbar)
2. Confirm the scrcpy window title matches the configuration
3. Check `logs\doubao-bridge.log` for errors

### Q: Clipboard not syncing?

Make sure scrcpy was not started with the `--no-clipboard-autosync` flag.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Windows Hotkeys | AutoHotkey v2.0 |
| Android App | Kotlin + Gradle |
| Screen Mirroring | scrcpy 3.x |
| Clipboard Sync | Built-in scrcpy feature (ADB) |

## License

MIT License

## Acknowledgments

- [scrcpy](https://github.com/Genymobile/scrcpy) — Powerful Android screen mirroring tool
- [AutoHotkey](https://www.autohotkey.com/) — Windows automation scripting language
- [Doubao](https://www.doubao.com/) — ByteDance AI Input Method
