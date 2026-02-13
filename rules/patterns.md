# 代码模式和亮点

## [2026-02-13] - Wolf Pack 插件完整创建

**类型**: highlight

**描述**
成功创建了完整的 Claude Code 插件，包含 23 个文件，涵盖：
- Hook 机制（规则持久化）
- 4 个命令（wolf-pack, wolf-insights, wolf-board, wolf-flow）
- 5 个技能
- 4 个预定义工作流
- Subagent 模板

**应用场景**
- Claude Code 插件开发
- 工作流自动化
- 项目规则管理

**可复用性**: 高

---

## [2026-02-13] - Claude Code 插件安装模式

**类型**: pattern

**描述**
Claude Code 插件需要安装到多个位置：

```bash
# 1. 插件缓存目录
~/.claude/plugins/cache/local/[plugin-name]/

# 2. 命令文件
~/.claude/commands/[command].md

# 3. 技能文件
~/.claude/skills/[skill-name]/SKILL.md

# 4. 注册插件
~/.claude/plugins/installed_plugins.json
```

**安装命令示例**:
```bash
# 复制插件文件
cp -r [plugin-source]/* ~/.claude/plugins/cache/local/[plugin-name]/

# 复制命令
cp [plugin-source]/commands/*.md ~/.claude/commands/

# 复制技能
mkdir -p ~/.claude/skills/[skill-name]/
cp [plugin-source]/skills/[skill-name]/SKILL.md ~/.claude/skills/[skill-name]/
```

**应用场景**
- 开发 Claude Code 插件
- 安装本地插件

**可复用性**: 高
