---
name: wolf-insights
description: 分析当前会话并提取洞察存储到项目记忆
---

# Wolf Insights 会话洞察分析

## 功能

分析会话历史，提取关键信息存储到 `.wolf/memory/`：

| 类型 | 存储位置 | 识别标志 |
|------|----------|----------|
| 问题 | issues/ | error, fail, bug, 卡住 |
| 决策 | decisions/ | 决策, 选择, 方案 |
| 模式 | patterns/ | usually, typically, 通常 |
| 亮点 | patterns/ | success, solved, 成功 |

## 存储格式

### issues.md

```markdown
## [YYYY-MM-DD] - [问题标题]

**类别**: [错误诊断|阻塞因素|依赖问题|知识缺口]

**上下文**
[描述问题发生的背景]

**尝试方案**
1. [尝试过的方法 1]

**最终方案**
[实际解决问题的方法]

**相关文件**
- `path/to/file1`
```

### patterns.md

```markdown
## [YYYY-MM-DD] - [模式/亮点]

**类型**: [pattern|highlight]

**描述**
[详细描述]

**应用场景**
- [场景 1]

**可复用性**: [高|中|低]
```

## 与 wolf-memory 集成

```yaml
执行流程:
  1. 分析会话历史
  2. 调用 wolf-memory save:
     - 问题 → /wolf-memory save issue
     - 模式 → /wolf-memory save pattern
     - 决策 → /wolf-memory save decision
  3. 更新索引: /wolf-memory update-index
```

## 自动触发

SessionEnd Hook 自动记录会话元数据，深度分析由 `/wolf-insights` 手动触发。
