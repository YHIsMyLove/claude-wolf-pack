---
argument-hint: [agent-count] [--agent-names name1,name2,...] [--team-name name] [--list]
description: 启动 Windows Terminal 分屏用于多 Agent 协作
---

# Wolf Terminal - Windows Terminal 分屏启动器

## 用法

```bash
/wolf-terminal                    # 默认 2 个分屏
/wolf-terminal 3                  # 启动 3 个分屏
/wolf-terminal --agent-names lead,researcher,coder  # 指定 Agent 名称
/wolf-terminal --team-name dev-team                # 指定团队名称
/wolf-terminal --list             # 列出活动的分屏会话
```

## 参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `agent-count` | 分屏数量 | 2 |
| `--agent-names` | Agent 名称列表（逗号分隔） | lead,researcher |
| `--team-name` | 团队名称 | wolf-pack |
| `--list` | 列出活动的分屏会话 | - |

## 分屏布局

```
┌─────────────────┬─────────────────┐
│   Lead Agent    │  Researcher     │
│                 │                 │
├─────────────────┴─────────────────┤
│  Coder / Third Agent              │
│                                   │
└───────────────────────────────────┘
```

- 第一个分屏：垂直分割 (-V)
- 后续分屏：水平分割 (-H)

## 环境变量

每个分屏自动设置：

```yaml
CLAUDE_CODE_TEAM_NAME: 团队名称
CLAUDE_CODE_AGENT_NAME: Agent 名称
CLAUDE_CODE_AGENT_ID: Agent 唯一标识
CLAUDE_CODE_PROJECT_PATH: 项目路径
```

## 环境要求

- **操作系统**: Windows 10/11
- **终端**: Windows Terminal（Microsoft Store）
- **Shell**: PowerShell 5.1+

## 限制

1. **Windows 专用** - 仅在 Windows 上有效
2. **手动启动** - 分屏创建后需在各窗口手动启动 agent
3. **辅助工具** - 此命令是 TeamCreate 的辅助启动器

---

**此命令调用 `wolf-terminal` 技能执行分屏启动。**
