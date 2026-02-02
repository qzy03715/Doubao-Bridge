# 开发计划文档

> 版本：1.0.0
> 更新日期：2026-02-02
> 状态：Phase 1 MVP

---

## 1. 开发阶段总览

```
Phase 1: MVP 验证
├── Step 1: 环境准备与验证
├── Step 2: 项目结构搭建
├── Step 3: AHK 脚本开发
├── Step 4: 集成测试
└── Step 5: 用户验收
```

---

## 2. Step 1: 环境准备与验证

### 2.1 验证 scrcpy 剪贴板同步

**目标**：确认 scrcpy 的剪贴板同步功能正常工作

**验证步骤**：

```
1. 启动 scrcpy
   命令：.\scrcpy -K --shortcut-mod=ralt --window-x -1000 --window-y 50 --max-fps 165 -b 20M -w

2. 在手机上打开便签 App，输入测试文字："测试剪贴板同步123"

3. 在手机上复制该文字（长按 → 全选 → 复制）

4. 在 PC 上打开记事本，按 Ctrl+V

5. 验证：粘贴的内容是否与手机上的一致？
```

**预期结果**：
- [ ] PC 能粘贴出手机上复制的内容
- [ ] 延迟在 1 秒以内

**问题排查**：

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 粘贴为空 | 剪贴板同步未开启 | 检查 scrcpy 参数 |
| 粘贴旧内容 | 同步延迟 | 等待更长时间 |
| 乱码 | 编码问题 | 检查 scrcpy 版本 |

### 2.2 验证 HID 键盘输入

**目标**：确认 scrcpy 的 HID 键盘模式能正确发送 Ctrl+A/C

**验证步骤**：

```
1. scrcpy 窗口激活状态
2. 在手机便签中输入一些文字
3. 在 PC 键盘上按 Ctrl+A
4. 验证：手机上的文字是否被全选？

5. 在 PC 键盘上按 Ctrl+C
6. 在 PC 记事本中按 Ctrl+V
7. 验证：内容是否正确粘贴？
```

**预期结果**：
- [ ] Ctrl+A 能触发全选
- [ ] Ctrl+C 能触发复制
- [ ] 剪贴板内容正确同步

### 2.3 确定输入容器 App

**目标**：选择一个合适的 Android App 作为输入容器

**候选 App 评估**：

| App | 启动速度 | Ctrl+A 支持 | 界面简洁度 | 推荐度 |
|-----|----------|-------------|------------|--------|
| 小米便签 | 快 | 待测试 | 中 | ★★★ |
| Google Keep | 中 | 待测试 | 高 | ★★★★ |
| 纯纯写作 | 快 | 是 | 高 | ★★★★★ |
| 系统备忘录 | 快 | 待测试 | 中 | ★★★ |

**测试方法**：

```
对每个候选 App：
1. 打开 App
2. 输入测试文字
3. 按 Ctrl+A，观察是否全选
4. 按 Ctrl+C，验证剪贴板
5. 记录结果
```

---

## 3. Step 2: 项目结构搭建

### 3.1 创建目录结构

```bash
# 创建目录
mkdir -p scripts
mkdir -p src/ahk
mkdir -p logs
mkdir -p config
```

### 3.2 创建启动脚本

**scripts/start-scrcpy.bat**：

```batch
@echo off
echo Starting scrcpy...
cd /d "C:\Users\Derpy\Desktop\scrcpy-win64-v3.3.3"
start "" scrcpy.exe -K --shortcut-mod=ralt --max-fps 165 -b 20M -w
echo scrcpy started.
```

**scripts/stop-scrcpy.bat**：

```batch
@echo off
echo Stopping scrcpy...
taskkill /IM scrcpy.exe /F
echo scrcpy stopped.
```

**scripts/start-ahk.bat**：

```batch
@echo off
echo Starting Doubao Bridge...
start "" "%ProgramFiles%\AutoHotkey\v2\AutoHotkey.exe" "%~dp0..\src\ahk\doubao-bridge.ahk"
echo Doubao Bridge started.
```

**scripts/stop-ahk.bat**：

```batch
@echo off
echo Stopping Doubao Bridge...
taskkill /IM AutoHotkey.exe /F
echo Doubao Bridge stopped.
```

---

## 4. Step 3: AHK 脚本开发

### 4.1 Task 3.1: 基础框架

**目标**：创建 AHK v2.0 脚本基础结构

**交付物**：`src/ahk/doubao-bridge.ahk`

**内容**：

```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force

; 配置类
class Config {
    static SCRCPY_TITLE := "2505APX7BC"
    static WIN_WIDTH := 400
    static WIN_HEIGHT := 700
}

; 全局变量
global LastWindowId := 0

; 启动提示
TrayTip("Doubao Bridge", "已启动，按 Alt+Space 唤起", 1)
```

**验证**：
- [ ] 脚本能正常启动
- [ ] 托盘显示启动提示
- [ ] 无语法错误

### 4.2 Task 3.2: 唤起热键

**目标**：实现 Alt+Space 唤起功能

**代码逻辑**：

```
!Space 按下:
    1. LastWindowId = WinGetID("A")      // 保存当前窗口
    2. if not WinExist(SCRCPY_TITLE):
           MsgBox("请先启动 scrcpy")
           return
    3. WinActivate(SCRCPY_TITLE)         // 激活窗口
    4. WinMove(..., x, y, w, h)          // 居中 + 调整大小
    5. Sleep(100)
    6. Send("^a")                        // 全选
    7. Sleep(50)
    8. Send("{Backspace}")               // 删除
```

**验证**：
- [ ] 按 Alt+Space 能激活 scrcpy 窗口
- [ ] 窗口位于屏幕中央
- [ ] 窗口大小正确
- [ ] 输入区被清空

### 4.3 Task 3.3: 上屏热键

**目标**：实现 Ctrl+Enter 上屏功能

**代码逻辑**：

```
^Enter 按下（仅 scrcpy 窗口激活时）:
    1. Send("^a")                        // 全选
    2. Sleep(50)
    3. Send("^c")                        // 复制
    4. Sleep(300)                        // 等待剪贴板同步
    5. WinMinimize(SCRCPY_TITLE)         // 最小化
    6. WinActivate(LastWindowId)         // 激活原窗口
    7. Sleep(100)
    8. Send("^v")                        // 粘贴
```

**验证**：
- [ ] 在 scrcpy 窗口按 Ctrl+Enter 能触发
- [ ] 内容被正确复制
- [ ] scrcpy 窗口最小化
- [ ] 原窗口重新激活
- [ ] 内容正确粘贴

### 4.4 Task 3.4: 错误处理

**目标**：添加基本的错误处理

**需要处理的错误**：

| 错误 | 检测方式 | 处理方式 |
|------|----------|----------|
| scrcpy 未运行 | `!WinExist()` | 弹出提示 |
| 原窗口已关闭 | `!WinExist(LastWindowId)` | 粘贴到当前活动窗口 |
| 剪贴板为空 | `A_Clipboard == ""` | 跳过粘贴，提示用户 |

### 4.5 Task 3.5: 日志记录

**目标**：添加简单的日志记录

**日志格式**：

```
[2026-02-02 14:30:15] [INFO] Doubao Bridge started
[2026-02-02 14:30:20] [INFO] Hotkey triggered: Alt+Space
[2026-02-02 14:30:20] [INFO] Saved window: 0x12345678
[2026-02-02 14:30:25] [INFO] Hotkey triggered: Ctrl+Enter
[2026-02-02 14:30:25] [INFO] Content transferred, length: 42
```

**日志文件**：`logs/doubao-bridge.log`

---

## 5. Step 4: 集成测试

### 5.1 端到端流程测试

**测试场景**：在 Word 中使用豆包语音输入

```
1. 打开 Microsoft Word，新建文档
2. 光标定位到文档中
3. 按 Alt+Space
4. 验证：scrcpy 窗口激活，居中，输入区清空
5. 点击豆包输入法的麦克风图标
6. 说一段话："今天天气真不错"
7. 确认识别结果正确
8. 按 Ctrl+Enter
9. 验证：文字出现在 Word 文档中
```

### 5.2 兼容性测试

**目标应用列表**：

| 应用 | 测试状态 | 备注 |
|------|----------|------|
| Microsoft Word | 待测试 | |
| 微信 PC 版 | 待测试 | |
| Chrome 浏览器 | 待测试 | |
| VS Code | 待测试 | |
| 记事本 | 待测试 | |

### 5.3 可靠性测试

**测试方法**：连续执行 10 次完整流程

**记录模板**：

| 次数 | 唤起成功 | 输入成功 | 上屏成功 | 备注 |
|------|----------|----------|----------|------|
| 1 | | | | |
| 2 | | | | |
| ... | | | | |
| 10 | | | | |

**成功率目标**：≥ 90%

---

## 6. Step 5: 用户验收

### 6.1 验收清单

| # | 验收项 | 状态 |
|---|--------|------|
| 1 | Alt+Space 能正常唤起 scrcpy | 待验收 |
| 2 | 窗口位置和大小符合预期 | 待验收 |
| 3 | 输入区能被清空 | 待验收 |
| 4 | 豆包语音输入可用 | 待验收 |
| 5 | Ctrl+Enter 能正常上屏 | 待验收 |
| 6 | 内容粘贴位置正确 | 待验收 |
| 7 | 连续使用 10 次成功率 ≥ 90% | 待验收 |

### 6.2 已知限制

| 限制 | 说明 | 后续改进方向 |
|------|------|--------------|
| 手动启动 scrcpy | 需要先手动启动 scrcpy | 一键启动脚本 |
| 手动打开输入容器 | 需要先手动打开便签 App | 自定义 App |
| 窗口有边框 | scrcpy 窗口带标题栏 | 去边框样式 |
| 偶尔剪贴板延迟 | 粘贴可能失败 | 增加重试机制 |

---

## 7. 开发检查点

### Checkpoint 1: 环境就绪

- [ ] scrcpy 剪贴板同步验证通过
- [ ] HID 键盘输入验证通过
- [ ] 输入容器 App 已选定
- [ ] AutoHotkey v2.0 已安装

### Checkpoint 2: 项目结构

- [ ] 目录结构创建完成
- [ ] 启动脚本编写完成
- [ ] Git 仓库初始化完成

### Checkpoint 3: 核心功能

- [ ] 唤起热键实现完成
- [ ] 上屏热键实现完成
- [ ] 错误处理添加完成
- [ ] 日志记录添加完成

### Checkpoint 4: 测试通过

- [ ] 端到端流程测试通过
- [ ] 兼容性测试通过
- [ ] 可靠性测试通过（≥ 90%）

### Checkpoint 5: 验收完成

- [ ] 用户验收清单全部通过
- [ ] 文档更新完成
- [ ] Git 提交完成

---

## 8. 依赖项

| 依赖 | 版本 | 安装状态 | 安装命令/路径 |
|------|------|----------|---------------|
| scrcpy | 3.3.3 | ✅ 已安装 | `C:\Users\Derpy\Desktop\scrcpy-win64-v3.3.3` |
| AutoHotkey | v2.0 | 待确认 | 官网下载安装 |
| 输入容器 App | - | 待选定 | 手机应用商店 |
| 豆包输入法 | - | ✅ 已安装 | 手机已配置 |

---

## 9. 开发顺序

```
1. [环境] 验证 scrcpy 剪贴板同步
        ↓
2. [环境] 验证 HID 键盘输入
        ↓
3. [环境] 确定输入容器 App
        ↓
4. [环境] 确认 AutoHotkey v2.0 安装
        ↓
5. [结构] 创建项目目录
        ↓
6. [结构] 编写启动脚本
        ↓
7. [开发] AHK 基础框架
        ↓
8. [开发] 唤起热键 (!Space)
        ↓
9. [开发] 上屏热键 (^Enter)
        ↓
10. [开发] 错误处理
        ↓
11. [开发] 日志记录
        ↓
12. [测试] 端到端测试
        ↓
13. [测试] 兼容性测试
        ↓
14. [测试] 可靠性测试
        ↓
15. [验收] 用户验收
```
