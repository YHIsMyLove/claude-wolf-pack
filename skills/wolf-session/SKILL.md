---
name: wolf-session
description: 管理会话状态和记录（跨平台支持）
---

# Wolf Session 技能

## 功能

此技能负责管理 Claude Code 会话的生命周期：

1. **会话开始** - 加载项目规则和记忆
2. **会话结束** - 记录洞察和文件变化
3. **状态查询** - 显示当前会话信息
4. **跨平台** - 自动检测 OS 并选择合适的脚本

---

## 一、平台检测

### 1.1 检测逻辑

```yaml
检测方法:
  - 检查 $env:OS 环境变量 (Windows)
  - 检查 $OSTYPE 环境变量 (Unix)
  - 检查 uname 命令输出

结果:
  - Windows_NT: 使用 PowerShell (.ps1)
  - 其他: 使用 Bash (.sh)
```

### 1.2 脚本路径

```yaml
Windows:
  SessionStart: hooks/session-start.ps1
  SessionEnd: hooks/session-end.ps1

Unix:
  SessionStart: hooks/session-start.sh
  SessionEnd: hooks/session-end.sh
```

---

## 二、会话开始

### 2.1 启动流程

```yaml
步骤:
  1. 检测平台
  2. 选择对应脚本
  3. 执行脚本

脚本功能:
  - 初始化规则目录
  - 读取项目规则 (.wolf.md)
  - 读取记忆系统 (rules/ 目录)
  - 加载记忆索引 (rules/index.md)
```

### 2.2 调用方式

```yaml
自动触发:
  - Claude Code 启动时
  - 会话恢复时
  - 清除上下文后

手动触发:
  命令: /wolf-session start
```

---

## 三、会话结束

### 3.1 结束流程

```yaml
步骤:
  1. 检测平台
  2. 选择对应脚本
  3. 执行脚本

脚本功能:
  - 记录文件变化 (通过 git)
  - 生成会话统计
  - 保存会话洞察
  - 更新记忆索引
```

### 3.2 文件变化追踪

```yaml
Git 项目:
  - git diff --name-only (修改)
  - git diff --cached --name-only (新增暂存)
  - git ls-files --others --exclude-standard (未跟踪)

非 Git 项目:
  - 记录基本信息
  - 标记为非 Git 项目
```

### 3.3 输出文件

```yaml
.wolf/trace/
  └── {date}-files.md    # 文件变化记录
  └── {date}-stats.md    # 会话统计

.claude/rules/
  └── .session-insights.md  # 会话洞察
  └── .session-log.txt      # 会话日志
```

---

## 四、状态查询

### 4.1 基本状态

```yaml
命令: /wolf-session

输出:
  - 会话 ID
  - 开始时间
  - 已用时间
  - 文件变化统计
```

### 4.2 详细状态

```yaml
命令: /wolf-session status

输出:
  - 基本状态信息
  - 记忆记录统计
  - 当前任务列表
  - 环境信息
```

### 4.3 会话摘要

```yaml
命令: /wolf-session summary

输出:
  - 本次会话的决策列表
  - 本次会话的问题列表
  - 本次会话的模式列表
  - 建议的后续操作
```

---

## 五、PowerShell 脚本实现

### 5.1 session-start.ps1

```powershell
# 主要函数
Initialize-RulesDir()     # 初始化规则目录结构
Safe-Read()               # 安全读取文件内容
Get-RuleFiles()           # 获取所有规则文件
Main()                    # 主逻辑

# 环境变量
$env:CLAUDE_PLUGIN_ROOT   # 插件根目录
$env:CLAUDE_PROJECT_ROOT  # 项目根目录
```

### 5.2 session-end.ps1

```powershell
# 主要函数
Initialize-Directories()  # 初始化目录
Write-SessionLog()        # 写入会话日志
Write-FileChanges()       # 记录文件变化
Write-SessionStats()      # 写入会话统计
Write-SessionInsights()   # 写入会话洞察
Get-GitRoot()             # 检测 Git 仓库
Main()                    # 主逻辑
```

---

## 六、Bash 脚本实现

### 6.1 session-start.sh

```bash
# 主要函数
init_rules_dir()          # 初始化规则目录
safe_read()               # 安全读取文件
list_rules()              # 列出规则文件
main()                    # 主逻辑
```

### 6.2 session-end.sh

```bash
# 主要函数
init_rules_dir()          # 初始化规则目录
init_trace_dir()          # 初始化跟踪目录
append_to_rule()          # 追加到规则文件
log_session()             # 记录会话日志
log_file_changes()        # 记录文件变化
log_session_stats()       # 记录会话统计
log_insights()            # 记录会话洞察
main()                    # 主逻辑
```

---

## 七、错误处理

```yaml
脚本不存在:
  - 输出错误提示
  - 提供安装/创建指引
  - 使用默认行为继续

权限不足:
  - Windows: 提示以管理员运行
  - Unix: 提示 chmod +x

目录创建失败:
  - 输出错误信息
  - 记录到日志文件
  - 使用临时目录
```

---

## 八、与记忆系统集成

```yaml
会话开始时:
  - 加载 .claude/rules/index.md
  - 读取决策、模式、问题记录
  - 注入到系统上下文

会话结束时:
  - 更新 .claude/rules/.session-insights.md
  - 记录新决策到 .claude/rules/decisions/
  - 记录新模式到 .claude/rules/patterns/
  - 记录新问题到 .claude/rules/issues/
```

---

## 九、使用示例

### 基础使用

```bash
# 查看会话状态
/wolf-session

# 手动记录会话
/wolf-session end

# 查看会话摘要
/wolf-session summary
```

### 与记忆系统集成

```bash
# 1. 开始会话（自动加载规则）
/wolf-session start

# 2. 执行工作流
/wolf-pack feature-dev

# 3. 记录决策
/wolf-memory save decision

# 4. 结束会话（自动记录）
/wolf-session end
```

---

## 十、配置文件

### hooks.json

```json
{
  "version": "1.0.0",
  "description": "跨平台 Hook 配置",
  "platforms": {
    "windows": {
      "shell": "powershell.exe",
      "extension": ".ps1"
    },
    "unix": {
      "shell": "bash",
      "extension": ".sh"
    }
  },
  "hooks": {
    "SessionStart": [...],
    "SessionEnd": [...]
  }
}
```

---

## 十一、调试

### 启用详细日志

```yaml
设置环境变量:
  $env:WOLF_DEBUG = "true"

效果:
  - 输出详细执行信息
  - 显示每个步骤的耗时
  - 记录到调试日志文件
```

### 日志文件位置

```yaml
Windows:
  $env:TEMP\wolf-session-debug.log

Unix:
  /tmp/wolf-session-debug.log
```
