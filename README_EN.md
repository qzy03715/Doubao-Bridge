# Doubao Bridge

[简体中文](./README.md) | English

Bridge the AI/voice input capabilities of the mobile **Doubao Input Method** to Windows PC via scrcpy + AutoHotkey. Supports both USB wired and **Wi-Fi wireless** screen casting modes.

## Features

- **Middle Mouse Button**: Smart detection — bring up casting window / one-click send to PC
- **Wi-Fi Wireless Casting**: Connect wirelessly over LAN, no cables needed
- **Always-on-Top Window**: Input window stays visible above other applications
- **Dedicated Android App**: Full-screen input field + quick phrases panel
- **Portable Design**: All tools bundled within the project folder

## How It Works

```
┌─────────────────────────────────────────────────────────┐
│  Middle Mouse Button — Smart Detection:                 │
│                                                         │
│  Window minimized → Press MButton → Show window (on top)│
│                                                         │
│  Window visible   → Press MButton → Copy from phone     │
│                                   → Paste to PC         │
│                                   → Clear phone notepad │
└─────────────────────────────────────────────────────────┘
```

## Requirements

- **OS**: Windows 10/11 (64-bit)
- **Android Phone**: Android 7.0+ (API 26+) with USB Debugging enabled
- **USB Cable**: Only needed for first-time setup; not required for daily Wi-Fi use
- **LAN**: For Wi-Fi mode, phone and PC must be on the same local network

## Quick Start

### Step 1: Clone the Repository

```bash
git clone https://github.com/qzy03715/Doubao-Bridge.git
cd Doubao-Bridge
```

### Step 2: Download Dependencies

The following tools are not included in the repository due to their size (~600MB). Download them manually into the `tools/` directory:

#### 2.1 Download scrcpy (Required)

1. Go to [scrcpy Releases](https://github.com/Genymobile/scrcpy/releases)
2. Download `scrcpy-win64-v3.x.zip`
3. **Extract to `tools\scrcpy\`**, ensuring `tools\scrcpy\scrcpy.exe` exists

#### 2.2 Download AutoHotkey v2 (Required)

1. Go to [AutoHotkey v2 Downloads](https://www.autohotkey.com/download/)
2. Download the **Portable** version (zip)
3. Extract to `tools\ahk\`, ensuring `tools\ahk\AutoHotkey64.exe` exists

#### 2.3 Deploy ADB (Required)

Copy the following files from `tools\scrcpy\` to `tools\adb\`:
- `adb.exe`
- `AdbWinApi.dll`
- `AdbWinUsbApi.dll`

#### 2.4 Download JDK 17 (Only for building the App)

1. Go to [Eclipse Temurin Downloads](https://adoptium.net/temurin/releases/?version=17)
2. Select **Windows x64** + **JDK** + **zip**
3. Download and extract to `tools\jdk\`
4. Ensure the path format is `tools\jdk\jdk-17.x.x+xx\bin\java.exe`

#### 2.5 Install Android SDK (Only for building the App)

```batch
scripts\setup-android-sdk.bat
```

### Step 3: Configure Device Identity

1. Connect your phone via USB, run scrcpy and note the window title (usually the device model, e.g. `2505APX7BC`)
2. Edit `src\ahk\config.json`, set `device.scrcpyTitle`:
   ```json
   "device": {
     "scrcpyTitle": "your-device-model"
   }
   ```

### Step 4: Build Android App (Optional)

```batch
scripts\build-android.bat
scripts\install-android.bat
```

Or manually install a pre-built APK if available.

### Step 5: Launch

**USB Wired Mode:**

```batch
scripts\start-all.bat
```

**Wi-Fi Wireless Mode (Recommended):**

```batch
:: First time: Connect phone via USB, run once to enable wireless mode
:: (auto-detects phone IP and writes to config)
scripts\enable-wifi-mode.bat

:: Daily use: Unplug USB, launch directly
scripts\start-wifi.bat
```

> Note: After phone reboot, re-run `enable-wifi-mode.bat` with USB connected.

## Usage

1. Run `scripts\start-wifi.bat` (or `start-all.bat`)
2. **Press Middle Mouse Button** → Bring up the casting window (always on top)
3. Use **Doubao Input Method** on your phone to type
4. **Click the target location** on PC (e.g., a chat input box)
5. **Press Middle Mouse Button** → Content auto-pasted, phone notepad cleared
6. Continue typing, repeat steps 4-5

## Configuration

Configuration file is at `src\ahk\config.json`:

```json
{
  "hotkey": {
    "trigger": "MButton",       // Trigger key: MButton/XButton1/XButton2/Alt+Space
    "cancel": "Escape"
  },
  "device": {
    "scrcpyTitle": "DeviceModel", // scrcpy window title (device model name)
    "ip": "192.168.0.87"          // Phone LAN IP (Wi-Fi mode; empty = USB mode)
  },
  "path": {
    "scrcpy": "tools\\scrcpy"    // scrcpy path (relative to project root)
  }
}
```

### Supported Hotkeys

| Config Value | Description |
|-------------|-------------|
| `MButton` | Middle mouse button |
| `XButton1` | Mouse side button 1 |
| `XButton2` | Mouse side button 2 |
| `Alt+Space` | Alt + Space |
| `Ctrl+Space` | Ctrl + Space |

## Project Structure

```
Doubao-Bridge/
├── docs/                          # Documentation
├── scripts/                       # Launch/build scripts
│   ├── start-all.bat              # One-click start (USB)
│   ├── start-wifi.bat             # One-click start (Wi-Fi)
│   ├── stop-all.bat               # One-click stop
│   ├── enable-wifi-mode.bat       # Enable Wi-Fi wireless mode
│   ├── update-wifi-config.ps1     # Wi-Fi config update helper
│   ├── build-android.bat          # Build APK
│   └── install-android.bat        # Install APK
├── src/
│   ├── ahk/
│   │   ├── doubao-bridge.ahk      # AHK main script
│   │   ├── config.json            # Configuration file
│   │   └── lib/                   # AHK libraries
│   └── android/                   # Android App source code
├── tools/                         # Tools directory (download manually)
│   ├── scrcpy/                    # scrcpy screen mirroring
│   ├── adb/                       # ADB tools
│   ├── ahk/                       # AutoHotkey v2
│   ├── jdk/                       # JDK 17 (for building)
│   └── android-sdk/               # Android SDK (for building)
└── logs/                          # Runtime logs
```

## FAQ

### Q: Middle mouse button not responding?

1. Confirm the AHK script is running (green H icon in taskbar)
2. Check that `scrcpyTitle` in `config.json` matches the scrcpy window title

### Q: Wi-Fi mode connection fails?

1. Ensure phone and PC are on the same LAN (same router/CPE)
2. Confirm `enable-wifi-mode.bat` completed successfully
3. After phone reboot, re-run `enable-wifi-mode.bat` (USB required)

### Q: Does Wi-Fi casting consume mobile data?

No. All scrcpy and adb communication is purely local network traffic between your phone and PC through the router. It does not go through the internet.

### Q: scrcpy shortcuts not working?

scrcpy uses `RAlt` as the shortcut modifier:
- `RAlt + H` — Home screen
- `RAlt + B` — Back
- `RAlt + S` — Switch app

### Q: Black borders on the casting window?

This happens if the window was manually resized. Restart scrcpy to fix.

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Windows Hotkeys | AutoHotkey v2.0 |
| Android App | Kotlin + Gradle |
| Screen Mirroring | scrcpy 3.x |
| Clipboard Sync | Built-in scrcpy (ADB) + ClipWait adaptive |
| Connection | USB / Wi-Fi (adb tcpip) |

## License

MIT License

## Acknowledgments

- [scrcpy](https://github.com/Genymobile/scrcpy) — Powerful Android screen mirroring tool
- [AutoHotkey](https://www.autohotkey.com/) — Windows automation scripting language
- [Doubao](https://www.doubao.com/) — ByteDance AI Input Method
