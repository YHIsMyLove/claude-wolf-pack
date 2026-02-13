---
paths: **/*.md
---

# 模式记忆

记录项目中可复用的成功模式和工作流。

## 格式规范

```markdown
---
id: [YYYYMMDD]-[slug]
type: pattern
category: [category]
tags: [tag1, tag2]
reusability: [high|medium|low]
created: [YYYY-MM-DD]
---

# [模式名称]

**类别**: [category]
**可复用性**: [high|medium|low]

## 描述
[详细描述]

## 应用场景
- [场景 1]
- [场景 2]

## 示例
\`\`\`language
[代码或命令示例]
\`\`\`

## 相关文件
- `path/to/file1`
```

## 子目录

- **component/**: 组件模式
- **api/**: API 设计模式
- **workflow/**: 工作流模式
- **architecture/**: 架构模式
