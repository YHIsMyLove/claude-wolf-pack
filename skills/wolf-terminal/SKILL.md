---
name: wolf-terminal
description: Windows Terminal 分屏启动器，TeamCreate 的辅助工具
---

# Wolf Terminal - Windows 分屏启动器

## 功能

为 Windows 用户提供多 Agent 分屏协作能力，是 TeamCreate 的辅助工具。

### 分屏布局

```
┌─────────────────┬─────────────────┐
│   Lead Agent    │  Researcher     │
│                 │                 │
├─────────────────┴─────────────────┤
│  Coder / Third Agent              │
│                                   │
└───────────────────────────────────┘
```

- 第一个分屏：水平中线分割（垂直布局）
- 后续分屏：水平布局

### 环境变量

每个分屏设置 Agent 身份：

```yaml
CLAUDE_CODE_TEAM_NAME: 团队名称
CLAUDE_CODE_AGENT_NAME: Agent 名称
CLAUDE_CODE_AGENT_ID: 唯一 ID
CLAUDE_CODE_PROJECT_PATH: 项目路径
```

## PowerShell 脚本

### 调用方式

```powershell
# 脚本路径
$scriptPath = "${ProjectRoot}/hooks/scripts/windows-terminal-split.ps1"

# 执行
& $scriptPath -AgentCount 3 -AgentNames @("lead", "researcher", "coder") -TeamName "wolf-pack"
```

### 权限配置

```json
// .claude/settings.local.json
{
  "permissions": {
    "allow": [
      "Bash(powershell.exe -File *windows-terminal-split.ps1*)"
    ]
  }
}
```

## 会话管理

### 标志文件

```yaml
文件: .wolf/team-active.flag
内容:
  {
    "teamName": "wolf-pack",
    "agentCount": 3,
    "agentNames": ["lead", "researcher", "coder"],
    "startedAt": "2026-02-20T10:30:00Z"
  }
```

### 查看状态

```bash
/wolf-terminal --list
```

## 环境要求

- **操作系统**: Windows 10/11
- **终端**: Windows Terminal
- **Shell**: PowerShell 5.1+

## 使用示例

```bash
# 默认 2 个分屏
/wolf-terminal

# 4 个分屏
/wolf-terminal 4

# 指定 Agent 名称
/wolf-terminal --agent-names lead,backend,frontend,qa
```

## 注意

此技能是 TeamCreate 的辅助工具，实际 Agent 协作由 TeamCreate 管理。
