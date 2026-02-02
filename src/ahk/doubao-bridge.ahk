; =============================================================================
; Doubao Bridge - Phase 3
; 功能：智能识别 - 呼出/上屏 二合一
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

global LastTriggerTime := 0
global TriggerDebounceMs := 300
global SavedWinX := -1
global SavedWinY := -1
global HasSavedPosition := false

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
    TrayTip("Doubao Bridge", trigger " = 呼出/上屏", 1)
}

OpenSettings(*) {
    port := CfgGet("system", "webPort", 23715)
    Run("http://localhost:" port)
}

; =============================================================================
; 快捷键解析
; =============================================================================

ParseHotkey(friendly) {
    result := friendly
    result := StrReplace(result, "鼠标中键", "MButton")
    result := StrReplace(result, "鼠标侧键1", "XButton1")
    result := StrReplace(result, "鼠标侧键2", "XButton2")
    result := StrReplace(result, "鼠标左键", "LButton")
    result := StrReplace(result, "鼠标右键", "RButton")
    result := StrReplace(result, "Middle Mouse", "MButton")
    result := StrReplace(result, "Mouse4", "XButton1")
    result := StrReplace(result, "Mouse5", "XButton2")
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
    Hotkey(trigger, HandleTrigger)
    LogWrite("[INIT] Trigger hotkey: " trigger)
}

; =============================================================================
; 智能触发：判断是呼出还是上屏
; =============================================================================

HandleTrigger(*) {
    global LastTriggerTime, TriggerDebounceMs

    ; 防抖
    now := A_TickCount
    if (now - LastTriggerTime) < TriggerDebounceMs {
        return
    }
    LastTriggerTime := now

    title := CfgGet("device", "scrcpyTitle", "")

    ; 检查 scrcpy 是否运行
    if !WinExist(title) {
        LogWrite("[ERROR] scrcpy not found")
        TrayTip("Doubao Bridge", "scrcpy not running!", 2)
        return
    }

    ; 判断 scrcpy 窗口状态
    isMinimized := (WinGetMinMax(title) = -1)
    isVisible := IsWindowVisible(title)

    if isMinimized || !isVisible {
        ; 窗口最小化或不可见 → 呼出窗口
        LogWrite("[ACTION] Show window")
        ShowScrcpyWindow()
    } else {
        ; 窗口已显示 → 上屏
        LogWrite("[ACTION] Send to PC")
        SendToPC()
    }
}

; =============================================================================
; 检查窗口是否在前台可见
; =============================================================================

IsWindowVisible(title) {
    if !WinExist(title)
        return false

    ; 检查是否最小化
    if WinGetMinMax(title) = -1
        return false

    ; 检查窗口是否被完全遮挡（简单判断：是否是活动窗口或 scrcpy 置顶）
    ; 这里简化处理：只要不是最小化就认为可见
    return true
}

; =============================================================================
; 呼出 scrcpy 窗口
; =============================================================================

ShowScrcpyWindow() {
    global SavedWinX, SavedWinY, HasSavedPosition

    title := CfgGet("device", "scrcpyTitle", "")

    ; 恢复窗口（如果最小化）
    if WinGetMinMax(title) = -1
        WinRestore(title)

    ; 只在有保存位置时恢复位置，不强制设置大小（避免黑边）
    if HasSavedPosition {
        ; 获取当前窗口大小，只改变位置
        try {
            WinGetPos(, , &w, &h, title)
            WinMove(SavedWinX, SavedWinY, w, h, title)
            LogWrite("[WINDOW] Restored position: " SavedWinX ", " SavedWinY)
        }
    }
    ; 首次不设置位置，让 scrcpy 自己决定

    ; 置顶显示
    WinSetAlwaysOnTop(1, title)

    ; 激活窗口（确保获得键盘焦点）
    WinActivate(title)
    WinWaitActive(title, , 1)
}

; =============================================================================
; 上屏：复制 Android 内容 → 粘贴到 PC
; =============================================================================

SendToPC() {
    global SavedWinX, SavedWinY, HasSavedPosition

    title := CfgGet("device", "scrcpyTitle", "")

    ; 保存当前窗口位置（用户可能移动过）
    try {
        WinGetPos(&wx, &wy, , , title)
        SavedWinX := wx
        SavedWinY := wy
        HasSavedPosition := true
    }

    ; 记录当前活动窗口（目标窗口）
    ; 如果当前活动窗口就是 scrcpy，需要找到之前的窗口
    activeTitle := ""
    try activeTitle := WinGetTitle("A")

    targetWinId := 0
    if InStr(activeTitle, title) {
        ; 当前在 scrcpy 窗口，无法直接获取目标
        ; 这种情况下用户应该先点击 PC 目标位置
        LogWrite("[WARN] Currently in scrcpy, no target window")
        TrayTip("Doubao Bridge", "请先点击 PC 目标位置", 2)
        return
    }

    try targetWinId := WinGetID("A")
    LogWrite("[SEND] Target: " targetWinId " (" activeTitle ")")

    ; 确保 scrcpy 置顶
    WinSetAlwaysOnTop(1, title)

    ; 激活 scrcpy 并复制
    WinActivate(title)
    if !WinWaitActive(title, , 0.5) {
        LogWrite("[ERROR] scrcpy activation failed")
        return
    }

    ; 全选 + 复制
    Sleep(30)
    Send("^a")
    Sleep(30)
    Send("^c")
    Sleep(CfgGet("behavior", "debounceMs", 200))

    ; 清空 Android 记事本内容（复制后立即清空）
    Send("{Backspace}")
    Sleep(30)

    ; 切回目标窗口并粘贴
    if targetWinId && WinExist("ahk_id " targetWinId) {
        WinActivate("ahk_id " targetWinId)
        WinWaitActive("ahk_id " targetWinId, , 0.5)
        Sleep(30)
        Send("^v")
        LogWrite("[SEND] Pasted to target")
    }

    ; 保持 scrcpy 置顶显示（不最小化，不激活）
    ; scrcpy 窗口保持在前台但焦点在目标窗口
    WinSetAlwaysOnTop(1, title)
}

; =============================================================================
; 启动
; =============================================================================

SetupTray()
RegisterHotkeys()
LogWrite("[INIT] Doubao Bridge Phase 3 started")
