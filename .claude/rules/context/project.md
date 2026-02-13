---
paths: **/*.md
---

# Wolf Pack 项目上下文

## 基本信息

- **项目名称**: Wolf Pack
- **项目类型**: Claude Code 插件
- **技术栈**: Bash, Markdown, JSON
- **目录结构**: 插件化架构，包含 commands、skills、agents、workflows

## 工作方式

1. **多文件功能开发前先展示架构** - 涉及 3+ 文件必须先展示文件结构、接口设计、模块依赖
2. **使用函数式思想** - 一个函数实现一个功能，避免副作用
3. **新增文档统一放到 docs/** - 虽然此项目使用 markdown 作为配置

## 插件规范

- **commands/**: 命令定义文件，使用 `argument-hint` 和 `description` frontmatter
- **skills/**: 技能定义文件，包含完整的用法和命令详解
- **workflows/**: 工作流定义 JSON
- **agents/**: Subagent 模板文件

## 记忆系统

项目使用 `.claude/rules/` 作为多层级记忆系统：
- **decisions/**: 技术决策记录
- **patterns/**: 可复用模式
- **issues/**: 问题与解决方案
- **context/**: 项目上下文
