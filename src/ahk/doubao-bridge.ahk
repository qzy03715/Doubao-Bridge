; =============================================================================
; Doubao Bridge - Phase 3 (简化版)
; 功能：一键上屏，投屏窗口保持显示
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

global LastTriggerTime := 0          ; 防抖：上次触发时间
global TriggerDebounceMs := 300      ; 防抖间隔（毫秒）

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
    TrayTip("Doubao Bridge", trigger " = 一键上屏", 1)
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
    Hotkey(trigger, HandleTrigger)
    LogWrite("[INIT] Trigger hotkey: " trigger)
}

; =============================================================================
; 一键上屏（核心逻辑）
; =============================================================================

HandleTrigger(*) {
    global LastTriggerTime, TriggerDebounceMs

    ; 防抖检查
    now := A_TickCount
    if (now - LastTriggerTime) < TriggerDebounceMs {
        LogWrite("[DEBOUNCE] Ignored, interval: " (now - LastTriggerTime) "ms")
        return
    }
    LastTriggerTime := now

    title := CfgGet("device", "scrcpyTitle", "")

    ; 检查 scrcpy 是否运行
    if !WinExist(title) {
        LogWrite("[ERROR] scrcpy not found: " title)
        TrayTip("Doubao Bridge", "scrcpy not running!", 2)
        return
    }

    ; 记录当前窗口（PC 上用户点击的目标窗口）
    targetWinId := 0
    try targetWinId := WinGetID("A")
    LogWrite("[SEND] Target window: " targetWinId)

    ; 如果当前已经在 scrcpy 窗口，目标就是上一个活动窗口
    ; 这种情况下直接从 scrcpy 复制并粘贴可能有问题
    ; 暂时不处理这个边界情况

    ; 激活 scrcpy 窗口
    WinActivate(title)
    if !WinWaitActive(title, , 1) {
        LogWrite("[ERROR] scrcpy activation timeout")
        return
    }

    ; 全选 + 复制（从 Android 记事本）
    Sleep(50)
    Send("^a")
    Sleep(50)
    Send("^c")

    ; 等待剪贴板同步（scrcpy 会自动同步 Android 剪贴板到 PC）
    Sleep(CfgGet("behavior", "debounceMs", 300))

    ; 回到目标窗口
    if targetWinId && WinExist("ahk_id " targetWinId) {
        WinActivate("ahk_id " targetWinId)
        if !WinWaitActive("ahk_id " targetWinId, , 1) {
            LogWrite("[WARN] Target window activation timeout")
        }
    }

    ; 粘贴
    Sleep(50)
    Send("^v")
    LogWrite("[SEND] Pasted, length: " StrLen(A_Clipboard))

    ; 注意：不最小化 scrcpy，保持显示
    ; 用户可以继续在 Android 输入，然后再按中键上屏
}

; =============================================================================
; 启动
; =============================================================================

SetupTray()
RegisterHotkeys()
LogWrite("[INIT] Doubao Bridge Phase 3 started (Simple Mode)")
