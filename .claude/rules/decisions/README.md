---
paths: **/*.md
---

# 决策记忆

记录项目中的重要技术决策及其理由。

## 格式规范

```markdown
---
id: [YYYYMMDD]-[slug]
type: decision
tags: [tag1, tag2]
priority: [high|medium|low]
created: [YYYY-MM-DD]
---

# [决策标题]

## 问题背景
[描述需要决策的问题]

## 考虑选项

| 选项 | 优点 | 缺点 |
|------|------|------|
| 选项 A | ... | ... |
| 选项 B | ... | ... |

## 最终选择
**[选择的选项]**

## 选择原因
[选择的原因]

## 影响范围
- [影响范围 1]
- [影响范围 2]

## 相关文件
- `path/to/file1`

## 标签
[tag1], [tag2]
```
