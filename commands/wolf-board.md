---
argument-hint: [--source=tasks|projects|issues|session] [--priority=high|medium|low] [--exec] [--breakdown]
description: 显示任务并拆解为可并行执行的单元
---

# Wolf Board - 任务看板

## 用法

### 显示看板

```bash
/wolf-board                           # 显示所有来源的任务
/wolf-board --source=tasks            # 只显示 Claude 内置任务
/wolf-board --source=projects         # 只显示项目文件任务
/wolf-board --source=issues           # 只显示记忆中的问题
/wolf-board --priority=high          # 只显示高优先级
```

### 选择并执行

```bash
/wolf-board --exec                    # 选择任务后自动执行工作流
```

### 任务拆解

```bash
/wolf-board --breakdown               # 拆解任务为可并行执行的单元
```

## 任务来源

| 来源 | 扫描路径 | 描述 |
|------|----------|------|
| tasks | ~/.claude/tasks/ | Claude 内置任务系统 |
| projects | TODO.md, TASKS.md | 项目文件中的任务 |
| issues | rules/issues.md | 记忆中未解决的问题 |
| session | 当前会话 | 从对话中识别的任务 |

## 输出格式

```
═════════════════════════════════════════════════════
  📋 Wolf Task Board
═════════════════════════════════════════════════════

📍 按优先级排序 (高 → 低)
─────────────────────────────────────────────────────

  [1] 🔴 HIGH    - [任务标题]
       来源: [tasks|projects|issues|session]
       预估: [时间]
       描述: [简要描述]

  [2] 🟡 MEDIUM  - [任务标题]
       来源: ...
       预估: ...

  [3] 🟢 LOW     - [任务标题]
       ...

─────────────────────────────────────────────────────
统计: N 个任务 | 预计: X 小时

选择任务编号，或使用 --breakdown 拆解任务:
```

## 任务拆解

使用 `--breakdown` 参数后，系统会将任务拆解为可并行执行的执行单元：

```
📋 任务拆解结果
════════════════════════════════════

任务: 实现用户认证模块

拆解为 3 个执行单元:

  [1] unit-auth-model
      描述: 定义用户数据模型和 schema
      文件: models/user.ts, schemas/user.schema.ts
      预估: 30 分钟
      依赖: 无

  [2] unit-auth-service
      描述: 实现认证服务（登录、注册）
      文件: services/auth.service.ts
      预估: 1 小时
      依赖: unit-auth-model

  [3] unit-auth-api
      描述: 实现 API 路由
      文件: api/auth.routes.ts
      预估: 45 分钟
      依赖: unit-auth-service

执行建议:
  第 1 层: unit-auth-model
  第 2 层: unit-auth-service
  第 3 层: unit-auth-api

或使用: /wolf-pack unit-auth-model unit-auth-service unit-auth-api
```

## 执行逻辑

1. 扫描所有来源的任务
2. 按优先级排序展示
3. 用户可选择：
   - 直接执行任务（调用工作流）
   - 拆解任务为执行单元
   - 并行执行多个单元

## 多 Agent 协同

| 问题 | 解决方案 |
|------|----------|
| 文件冲突 | 执行单元声明文件，重叠则顺序执行 |
| 依赖关系 | 单元间依赖声明，自动排序 |
| 上下文共享 | 所有单元接收统一项目上下文 |

## 任务优先级规则

- 🔴 **HIGH**: 阻塞问题、安全漏洞、数据丢失风险
- 🟡 **MEDIUM**: 功能需求、重构、性能优化
- 🟢 **LOW**: 文档更新、样式调整、nice-to-have

---

**此命令调用 `wolf-board` 技能执行实际任务聚合与拆解。**
