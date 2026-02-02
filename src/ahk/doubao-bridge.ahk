; =============================================================================
; Project Doubao-Bridge - 主脚本
; 功能：通过快捷键桥接 scrcpy 与 PC 软件，实现豆包输入法跨端输入
; AHK 版本：v2.0
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; 配置
; =============================================================================

class Config {
    static SCRCPY_TITLE := "2505APX7BC"
    static WIN_WIDTH := 400
    static WIN_HEIGHT := 700
    static CLIP_WAIT_MS := 300
    static KEY_DELAY_MS := 50
    static LOG_FILE := A_ScriptDir "\..\..\logs\doubao-bridge.log"
}

; =============================================================================
; 全局状态
; =============================================================================

global LastWindowId := 0

; =============================================================================
; 日志
; =============================================================================

LogWrite(msg) {
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    line := "[" timestamp "] " msg "`n"
    try FileAppend(line, Config.LOG_FILE)
}

; =============================================================================
; 启动提示
; =============================================================================

LogWrite("[INFO] Doubao Bridge 已启动")
TrayTip("Doubao Bridge 已启动", "Alt+Space 唤起 | Ctrl+Enter 上屏", 1)

; =============================================================================
; 热键：Alt + Space - 唤起 scrcpy 窗口
; =============================================================================

!Space:: {
    global LastWindowId

    ; 记录当前窗口句柄
    LastWindowId := WinGetID("A")
    LogWrite("[INFO] 唤起 | 原窗口句柄: " LastWindowId)

    ; 检查 scrcpy 是否运行
    if !WinExist(Config.SCRCPY_TITLE) {
        LogWrite("[ERROR] scrcpy 窗口未找到")
        MsgBox("scrcpy 未运行，请先启动 scrcpy。", "Doubao Bridge", "Icon!")
        return
    }

    ; 激活 scrcpy 窗口
    WinActivate(Config.SCRCPY_TITLE)

    ; 如果窗口处于最小化，先恢复
    if WinGetMinMax(Config.SCRCPY_TITLE) = -1 {
        WinRestore(Config.SCRCPY_TITLE)
    }

    ; 计算屏幕中心位置
    posX := (A_ScreenWidth - Config.WIN_WIDTH) // 2
    posY := (A_ScreenHeight - Config.WIN_HEIGHT) // 2

    ; 移动并调整窗口大小
    WinMove(posX, posY, Config.WIN_WIDTH, Config.WIN_HEIGHT, Config.SCRCPY_TITLE)

    ; 等待窗口激活
    if !WinWaitActive(Config.SCRCPY_TITLE, , 1) {
        LogWrite("[ERROR] scrcpy 窗口激活超时")
        return
    }

    ; 清空输入区：全选 + 删除
    Sleep(100)
    Send("^a")
    Sleep(Config.KEY_DELAY_MS)
    Send("{Backspace}")

    LogWrite("[INFO] 唤起完成")
}

; =============================================================================
; 条件热键：Ctrl + Enter - 上屏（仅 scrcpy 窗口激活时）
; =============================================================================

#HotIf WinActive(Config.SCRCPY_TITLE)
^Enter:: {
    global LastWindowId

    LogWrite("[INFO] 上屏开始")

    ; 全选
    Send("^a")
    Sleep(Config.KEY_DELAY_MS)

    ; 复制
    Send("^c")
    Sleep(Config.CLIP_WAIT_MS)

    ; 最小化 scrcpy
    WinMinimize(Config.SCRCPY_TITLE)

    ; 还原焦点到原窗口
    if LastWindowId && WinExist("ahk_id " LastWindowId) {
        WinActivate("ahk_id " LastWindowId)
        if !WinWaitActive("ahk_id " LastWindowId, , 1) {
            LogWrite("[WARN] 原窗口激活超时，尝试粘贴到当前窗口")
        }
    } else {
        LogWrite("[WARN] 原窗口不存在，粘贴到当前活动窗口")
    }

    Sleep(100)

    ; 粘贴
    Send("^v")

    LogWrite("[INFO] 上屏完成 | 内容长度: " StrLen(A_Clipboard))
}
#HotIf
