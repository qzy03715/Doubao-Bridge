; =============================================================================
; Doubao Bridge - Phase 3
; 功能：单一快捷键 + 剪贴板监听自动上屏 + 窗口置顶
; AHK 版本：v2.0
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "lib\Jxon.ahk"

; =============================================================================
; 配置加载
; =============================================================================

global Cfg := LoadConfig()

LoadConfig() {
    configPath := A_ScriptDir "\config.json"
    if !FileExist(configPath) {
        MsgBox("config.json not found!`n" configPath, "Doubao Bridge", "Icon!")
        ExitApp()
    }
    text := FileRead(configPath, "UTF-8")
    return Jxon.Load(text)
}

CfgGet(section, key, default := "") {
    global Cfg
    try return Cfg[section][key]
    catch
        return default
}

; =============================================================================
; 全局状态
; =============================================================================

global State := "IDLE"
global LastWindowId := 0
global IgnoreClip := false
global LastClipContent := ""
global LastTriggerTime := 0          ; 防抖：上次触发时间
global TriggerDebounceMs := 500      ; 防抖间隔（毫秒）
global TopMostTimer := 0             ; 置顶保持定时器
global SavedWinX := -1               ; 记住的窗口位置 X
global SavedWinY := -1               ; 记住的窗口位置 Y
global HasSavedPosition := false     ; 是否已保存过位置

; =============================================================================
; 日志
; =============================================================================

LogWrite(msg) {
    logFile := A_ScriptDir "\..\..\logs\doubao-bridge.log"
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    try FileAppend("[" timestamp "] " msg "`n", logFile)
}

; =============================================================================
; 托盘菜单
; =============================================================================

SetupTray() {
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Doubao Bridge v3", (*) => "")
    A_TrayMenu.Disable("Doubao Bridge v3")
    A_TrayMenu.Add()
    A_TrayMenu.Add("Open Settings", OpenSettings)
    A_TrayMenu.Add("Restart", (*) => Reload())
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    A_TrayMenu.Default := "Open Settings"

    trigger := CfgGet("hotkey", "trigger", "MButton")
    TrayTip("Doubao Bridge", trigger " to activate", 1)
}

OpenSettings(*) {
    port := CfgGet("system", "webPort", 23715)
    Run("http://localhost:" port)
}

; =============================================================================
; 快捷键解析（支持键盘和鼠标）
; =============================================================================

ParseHotkey(friendly) {
    result := friendly
    ; 中文友好名称
    result := StrReplace(result, "鼠标中键", "MButton")
    result := StrReplace(result, "鼠标侧键1", "XButton1")
    result := StrReplace(result, "鼠标侧键2", "XButton2")
    result := StrReplace(result, "鼠标左键", "LButton")
    result := StrReplace(result, "鼠标右键", "RButton")
    ; 英文友好名称
    result := StrReplace(result, "Middle Mouse", "MButton")
    result := StrReplace(result, "Mouse4", "XButton1")
    result := StrReplace(result, "Mouse5", "XButton2")
    ; 修饰键
    result := StrReplace(result, "Ctrl+", "^")
    result := StrReplace(result, "Alt+", "!")
    result := StrReplace(result, "Shift+", "+")
    result := StrReplace(result, "Win+", "#")
    return result
}

; =============================================================================
; 热键注册
; =============================================================================

RegisterHotkeys() {
    trigger := ParseHotkey(CfgGet("hotkey", "trigger", "MButton"))
    cancel := ParseHotkey(CfgGet("hotkey", "cancel", "Escape"))
    title := CfgGet("device", "scrcpyTitle", "")

    ; 全局触发键
    Hotkey(trigger, HandleTrigger)

    ; 取消键（仅 scrcpy 窗口激活时）
    HotIf((*) => WinActive(title))
    Hotkey(cancel, HandleCancel)
    HotIf()

    LogWrite("[INIT] Trigger: " trigger ", Cancel: " cancel)
}

; =============================================================================
; 触发处理（状态机核心 + 防抖）
; =============================================================================

HandleTrigger(*) {
    global State, LastTriggerTime, TriggerDebounceMs

    ; 防抖检查：避免长按/快速点击重复触发
    now := A_TickCount
    if (now - LastTriggerTime) < TriggerDebounceMs {
        LogWrite("[DEBOUNCE] Trigger ignored, interval: " (now - LastTriggerTime) "ms")
        return
    }
    LastTriggerTime := now

    if State = "IDLE"
        ActivateInput()
    else
        ManualSend()
}

; =============================================================================
; 激活输入模式 (IDLE → ACTIVE)
; =============================================================================

ActivateInput() {
    global State, LastWindowId, LastClipContent

    title := CfgGet("device", "scrcpyTitle", "")

    ; 记录当前窗口
    try LastWindowId := WinGetID("A")
    LogWrite("[ACTIVATE] Original window: " LastWindowId)

    ; 检查 scrcpy
    if !WinExist(title) {
        LogWrite("[ERROR] scrcpy not found: " title)
        TrayTip("Doubao Bridge", "scrcpy not running!", 2)
        return
    }

    ; 激活 scrcpy
    WinActivate(title)
    if WinGetMinMax(title) = -1
        WinRestore(title)

    ; 设置窗口置顶（防止被其他窗口遮挡）
    WinSetAlwaysOnTop(1, title)

    ; 调整窗口大小和位置
    w := CfgGet("window", "width", 400)
    h := CfgGet("window", "height", 700)

    if HasSavedPosition {
        ; 使用上次保存的位置
        WinMove(SavedWinX, SavedWinY, w, h, title)
        LogWrite("[WINDOW] Restored position: " SavedWinX ", " SavedWinY)
    } else {
        ; 首次激活：居中显示
        posX := (A_ScreenWidth - w) // 2
        posY := (A_ScreenHeight - h) // 2
        WinMove(posX, posY, w, h, title)
        LogWrite("[WINDOW] Centered: " posX ", " posY)
    }

    if !WinWaitActive(title, , 1) {
        LogWrite("[ERROR] scrcpy activation timeout")
        WinSetAlwaysOnTop(0, title)
        return
    }

    ; 清空输入区
    if CfgGet("behavior", "clearOnActivate", true) {
        Sleep(100)
        Send("^a")
        Sleep(50)
        Send("{Backspace}")
    }

    ; 记录当前剪贴板内容（用于变化检测）
    LastClipContent := A_Clipboard

    ; 切换状态
    State := "ACTIVE"
    LogWrite("[STATE] IDLE -> ACTIVE")

    ; 启动置顶保持定时器（每 100ms 检查一次）
    SetTimer(KeepTopMost, 100)
}

; =============================================================================
; 置顶保持（定时器回调）
; =============================================================================

KeepTopMost() {
    global State
    if State != "ACTIVE" {
        SetTimer(KeepTopMost, 0)  ; 停止定时器
        return
    }

    title := CfgGet("device", "scrcpyTitle", "")
    if WinExist(title) {
        WinSetAlwaysOnTop(1, title)
    }
}

; =============================================================================
; 手动上屏 (ACTIVE 时再次按触发键)
; =============================================================================

ManualSend() {
    global State, IgnoreClip

    LogWrite("[SEND] Manual send triggered")

    ; 忽略接下来的剪贴板变化（避免重复触发）
    IgnoreClip := true

    ; 复制内容
    Send("^a")
    Sleep(50)
    Send("^c")
    Sleep(CfgGet("behavior", "debounceMs", 200))

    ; 返回原窗口并粘贴
    ReturnToOriginal(true)

    IgnoreClip := false
}

; =============================================================================
; 取消输入 (Esc)
; =============================================================================

HandleCancel(*) {
    global State
    if State != "ACTIVE"
        return

    LogWrite("[CANCEL] User cancelled")
    ReturnToOriginal(false)
}

; =============================================================================
; 剪贴板监听
; =============================================================================

ClipChanged(dataType) {
    global State, IgnoreClip, LastClipContent

    ; 仅 ACTIVE 状态响应
    if State != "ACTIVE"
        return

    ; 忽略自己的操作
    if IgnoreClip
        return

    ; 仅处理文本
    if dataType != 1
        return

    ; 内容相同则忽略
    if A_Clipboard = LastClipContent
        return

    ; 空内容忽略
    if A_Clipboard = ""
        return

    LogWrite("[CLIP] Content changed, length: " StrLen(A_Clipboard))

    ; 防抖：延迟执行
    debounce := CfgGet("behavior", "debounceMs", 200)
    SetTimer(DoAutoSend, -debounce)
}

DoAutoSend() {
    global State
    if State != "ACTIVE"
        return

    LogWrite("[SEND] Auto send triggered")
    ReturnToOriginal(true)
}

; =============================================================================
; 返回原窗口
; =============================================================================

ReturnToOriginal(shouldPaste) {
    global State, LastWindowId

    title := CfgGet("device", "scrcpyTitle", "")

    ; 停止置顶保持定时器
    SetTimer(KeepTopMost, 0)

    ; 保存当前窗口位置（用户可能手动移动过）
    if WinExist(title) {
        try {
            WinGetPos(&wx, &wy, , , title)
            SavedWinX := wx
            SavedWinY := wy
            HasSavedPosition := true
            LogWrite("[WINDOW] Saved position: " wx ", " wy)
        }
    }

    ; 取消窗口置顶
    if WinExist(title)
        WinSetAlwaysOnTop(0, title)

    ; 最小化 scrcpy
    if WinExist(title)
        WinMinimize(title)

    ; 激活原窗口
    if LastWindowId && WinExist("ahk_id " LastWindowId) {
        WinActivate("ahk_id " LastWindowId)
        WinWaitActive("ahk_id " LastWindowId, , 1)
    }

    ; 粘贴
    if shouldPaste && CfgGet("behavior", "autoPaste", true) {
        Sleep(100)
        Send("^v")
        LogWrite("[PASTE] Length: " StrLen(A_Clipboard))
    }

    ; 重置状态
    State := "IDLE"
    LogWrite("[STATE] ACTIVE -> IDLE")
}

; =============================================================================
; 启动
; =============================================================================

SetupTray()
RegisterHotkeys()
OnClipboardChange(ClipChanged)
LogWrite("[INIT] Doubao Bridge Phase 3 started")
