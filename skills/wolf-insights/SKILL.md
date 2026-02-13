---
name: wolf-insights
description: 分析当前会话并提取洞察存储到项目记忆 (.wolf/memory/)
---

# Wolf Insights 会话洞察分析技能

## 功能

此技能分析当前会话历史，提取关键信息并存储到项目的 `.wolf/memory/` 目录：

1. **问题识别** → `.wolf/memory/issues/`
2. **决策发现** → `.wolf/memory/decisions/`
3. **模式发现** → `.wolf/memory/patterns/`
4. **亮点捕捉** → `.wolf/memory/patterns/`

## 分析流程

### 1. 扫描会话历史

```yaml
扫描范围:
  - 最近的对话轮次
  - 错误和失败
  - 解决方案
  - 决策点

关注事件:
  - 错误消息
  - 重复操作
  - 成功模式
  - 用户偏好
```

### 2. 分类提取

```yaml
问题 (issues):
  - 错误类型
  - 阻塞因素
  - 依赖问题
  - 知识缺口

模式 (patterns):
  - 代码惯例
  - 架构模式
  - 工作流方式

亮点 (highlights):
  - 成功路径
  - 高效方法
  - 工具组合
```

### 3. 追加存储

```yaml
规则目录: rules/

issues.md:
  ## [YYYY-MM-DD] - [问题标题]
  **上下文**: ...
  **尝试方案**: ...
  **最终方案**: ...
  **相关文件**: ...

patterns.md:
  ## [YYYY-MM-DD] - [模式/亮点]
  **类型**: [pattern/highlight]
  **描述**: ...
  **可复用**: ...
```

## 分析维度详解

### 问题识别

| 类别 | 识别标志 | 存储位置 |
|------|----------|----------|
| 错误诊断 | Error, Exception, Failed | issues.md |
| 阻塞因素 | 卡住、无法继续 | issues.md |
| 依赖问题 | npm/yarn/pip 错误 | issues.md |
| 知识缺口 | "不知道", "学习" | issues.md |

### 亮点捕捉

| 类别 | 识别标志 | 存储位置 |
|------|----------|----------|
| 成功路径 | "成功"、"解决" | patterns.md |
| 高效模式 | 快速完成 | patterns.md |
| 工具使用 | 命令组合 | patterns.md |

### 模式发现

| 类别 | 识别标志 | 存储位置 |
|------|----------|----------|
| 代码惯例 | 重复代码风格 | patterns.md |
| 架构模式 | 设计模式应用 | patterns.md |
| 工作流 | 操作顺序 | patterns.md |

## 存储格式

### issues.md

```markdown
## [YYYY-MM-DD] - [简短问题标题]

**类别**: [错误诊断|阻塞因素|依赖问题|知识缺口]

**上下文**
[描述问题发生的背景]

**尝试方案**
1. [尝试过的方法 1]
2. [尝试过的方法 2]

**最终方案**
[实际解决问题的方法]

**相关文件**
- `path/to/file1`
- `path/to/file2`

**标签**: [tag1, tag2]
```

### patterns.md

```markdown
## [YYYY-MM-DD] - [简短标题]

**类型**: [pattern|highlight]

**描述**
[详细描述]

**应用场景**
- [场景 1]
- [场景 2]

**可复用性**: [高|中|低]

**示例**
```
[代码或命令示例]
```
```

## 分析策略

### 深度分析

```yaml
1. 时间范围:
   - 默认: 最近 50 轮对话
   - 可配置: --depth=N

2. 关键词匹配:
   - 问题: error, fail, issue, bug, 问题
   - 成功: success, resolved, solved, 解决
   - 模式: usually, typically, 总是, 通常

3. 情感分析:
   - 负面 → 问题
   - 正面 → 亮点
   - 中性 → 模式
```

### 去重机制

```yaml
避免重复:
  - 检查现有条目
  - 比相似度
  - 只追加新内容

更新策略:
  - 相似但不完全相同 → 更新现有条目
  - 完全新内容 → 追加新条目
```

## 输出格式

### summary 模式

```markdown
🔍 洞察分析完成

📊 统计:
  - 3 个问题 → rules/issues.md
  - 2 个亮点 → rules/patterns.md
  - 1 个模式 → rules/patterns.md

📝 主要发现:
  1. [问题 1 简述]
  2. [亮点 1 简述]
  3. [模式 1 简述]
```

### detailed 模式

```markdown
🔍 洞察分析完成

## 问题 (3)
### 1. [问题标题]
上下文: ...
方案: ...

## 亮点 (2)
### 1. [亮点标题]
描述: ...

## 模式 (1)
### 1. [模式标题]
描述: ...
```

## 参数处理

```yaml
--category:
  issues: 只分析问题
  patterns: 只分析模式和亮点
  highlights: 只分析亮点
  (默认): 分析全部

--output:
  summary: 只返回摘要
  detailed: 返回详细分析
  (默认): detailed
```

## 自动触发

通过 SessionEnd Hook 自动触发简化版分析：
- 只记录会话元数据
- 不执行深度分析
- 深度分析由 /wolf-insights 手动触发

---

## 与 wolf-memory 集成

```yaml
/wolf-insights 执行流程:

1. 分析会话历史
   - 扫描最近对话
   - 识别问题/模式/亮点/决策

2. 调用 wolf-memory save
   - 问题 → /wolf-memory save issue
   - 模式 → /wolf-memory save pattern
   - 决策 → /wolf-memory save decision
   - 亮点 → /wolf-memory save pattern (type=highlight)

3. 更新索引
   - 调用 /wolf-memory update-index

4. 返回分析结果
```

**注意**: 分析完成后，所有提取的内容自动存储到 `.wolf/memory/` 目录。
