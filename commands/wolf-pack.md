---
argument-hint: [workflow-name | [exec-unit...]] [create|list|validate] [--dry-run] [--force]
description: 执行工作流或并行执行单元（使用 Agent Team）
---

# Wolf Pack - 工作流执行与并行调度

## 用法

### 工作流模式

```bash
/wolf-pack [workflow-name]       # 执行预定义工作流
/wolf-pack feature-dev --dry-run # 预览执行
/wolf-pack multi-debug           # 多问题并行调试
```

### 工作流管理

```bash
/wolf-pack create                # 创建新工作流
/wolf-pack list                  # 列出所有工作流
/wolf-pack validate [workflow-name]  # 验证工作流
```

### 并行执行单元模式

```bash
/wolf-pack unit1 unit2 unit3     # 并发执行多个单元
```

### 参数

| 参数 | 说明 |
|------|------|
| `workflow-name` | 工作流名称 (multi-debug, feature-dev, refactor, task-board) |
| `exec-unit...` | 一个或多个执行单元，并发执行 |
| `--dry-run` | 只显示将要执行的任务，不实际执行 |
| `--force` | 跳过破坏性操作确认 |

## 预定义工作流

| 工作流 | 用途 | 并发 |
|--------|------|------|
| multi-debug | 多问题并行调试 | 是 |
| feature-dev | 完整功能开发 | 否 |
| refactor | 代码重构 | 部分 |
| task-board | 任务看板执行 | 是 |

## 前置条件检查

执行前检查以下内容：

1. **工作流存在性** - 验证工作流文件存在
2. **前置条件** - 检查工作流中定义的 preconditions
3. **验收标准** - 加权评分，达到阈值才执行
4. **破坏性检查** - 如涉及删除/覆盖，需要用户确认

### 加权评分表

| 检查项 | 权重 | 说明 |
|--------|------|------|
| dependencies_installed | 10 | 依赖已安装 |
| project_clean | 15 | 项目状态干净 |
| tests_passing | 20 | 测试通过 |
| config_files_exist | 10 | 配置文件存在 |
| environment_ready | 15 | 环境就绪 |

## Agent Team 模式

默认使用 Claude Code 官方 Agent Team 系统：

```yaml
执行流程:
  1. TeamCreate(team_name, description)  # 创建团队
  2. TaskCreate(...)                     # 创建任务
  3. TaskUpdate(owner/blockedBy)         # 分配和设置依赖
  4. SendMessage(broadcast)              # 通知开始
  5. TaskList()                          # 监控进度
  6. SendMessage(shutdown_request)       # 关闭 teammate
  7. TeamDelete()                        # 删除团队
```

## 并行执行单元

执行单元是由 `/wolf-board` 拆解生成的可并行执行的任务单元。

```yaml
执行单元格式:
  unit_id: 唯一标识
  description: 简要描述
  files: 涉及文件
  dependencies: 依赖的 unit_id
  estimated_time: 预估时间
```

## 执行示例

```bash
# 工作流执行
/wolf-pack multi-debug           # 多问题并行调试
/wolf-pack feature-dev           # 功能开发流程
/wolf-pack refactor              # 重构工作流

# 工作流管理
/wolf-pack create                # 交互式创建工作流
/wolf-pack list                  # 列出所有工作流
/wolf-pack validate feature-dev  # 验证工作流

# 并行执行
/wolf-pack auth-module user-api  # 并发执行两个单元
```

## Windows 用户多 Agent 支持

如需多 Agent 并行执行，可先使用 `/wolf-terminal` 启动分屏，然后执行工作流。

## 工作流格式

工作流定义在 `workflows/*.md` 中，包含：

- **触发条件** - 什么情况下使用此工作流
- **前置条件** - preconditions 检查项和阈值
- **破坏性操作** - 需要确认的危险操作
- **执行步骤** - 并发/顺序执行的步骤列表

### 创建工作流

```markdown
## [工作流名称]

### 描述
[工作流的简短描述]

### 触发条件
[什么情况下使用此工作流]

### 前置条件 (preconditions)

```yaml
checks:
  - name: dependencies_installed
    description: 检查所需依赖是否已安装
    weight: 10
  # ...

threshold: 60

destructive:
  - delete_files: true
```

### 执行配置
- **模式**: strict | lenient
- **偏差处理**: track | block | warn

### 步骤

#### Step 1: [步骤名称]
- **关键**: true/false
- **依赖**: []
- **Agent**: general-purpose
- **并行**: false
- **输出**: [预期结果]
- **验收**: [如何验证完成]

[步骤详细描述...]

#### Step 2: ...
```

---

**此命令调用 `wolf-pack` 技能执行工作流或并行调度。**
