---
name: wolf-board
description: 汇总任务并拆解为可并行执行的单元
---

# Wolf Board 任务看板与拆解技能

## 功能

此技能从多个来源聚合任务，并支持拆解为可并行执行的执行单元：

1. **多源聚合** - 扫描不同来源的任务
2. **优先级排序** - 按重要性排序
3. **过滤选择** - 支持按来源/优先级过滤
4. **任务拆解** - 将任务拆解为可并行的执行单元
5. **执行集成** - 选择后自动执行工作流或并行调度

---

## 一、任务来源扫描

### 1.1 Claude 内置任务

```yaml
路径: ~/.claude/tasks/

解析:
  - 读取 tasks.json 或相关文件
  - 提取: title, status, priority, description

默认优先级:
  - 未设置 → MEDIUM
```

### 1.2 项目文件任务

```yaml
路径: TODO.md, TASKS.md

解析 Markdown:
  ## [ ] 未完成任务 → LOW
  ## [!] 重要任务 → HIGH
  ## [-] 进行中 → MEDIUM

支持格式:
  - - [ ] 任务描述
  - - [!] 重要: 任务描述
  - ### 任务标题
      - [ ] 子任务
```

### 1.3 记忆中的问题

```yaml
路径: rules/issues.md

解析:
  - 读取未解决的问题
  - 标记未解决的 → HIGH
  - 近期的问题 → MEDIUM

默认优先级: HIGH (因为是问题)
```

### 1.4 当前会话

```yaml
来源: 对话历史

识别:
  - "TODO": ...
  - "需要": ...
  - "记住": ...
  - "待办": ...

默认优先级: MEDIUM
```

---

## 二、任务拆解（新增）

### 2.1 拆解原则

```yaml
拆解目标:
  - 按文件边界拆分 (避免冲突)
  - 按功能模块拆分 (高内聚)
  - 按依赖关系排序

输入: 一个任务描述
输出: 执行单元列表
```

### 2.2 执行单元数据结构

```yaml
ExecUnit:
  id: string                  # 唯一标识 (如: auth-model)
  description: string          # 简要描述
  files: string[]              # 涉及文件
  dependencies: string[]       # 依赖的 unit id
  estimated_time: string       # 预估时间
  priority: high|medium|low    # 优先级
  agent_type: string           # agent 类型
```

### 2.3 拆解算法

```yaml
步骤 1: 分析任务类型
  - bug/问题 → 按文件拆分
  - 功能开发 → 按模块拆分
  - 重构 → 按影响范围拆分

步骤 2: 识别涉及文件
  - 询问或分析相关文件
  - 按目录结构分组

步骤 3: 构建依赖图
  - 分析模块间依赖
  - 确定执行顺序

步骤 4: 生成执行单元
  - 每个单元独立可执行
  - 标注文件和依赖
```

### 2.4 拆解示例

#### 示例 1: 功能开发

```yaml
任务: 实现用户认证功能

拆解结果:
  - unit-1: 定义用户模型
    files: [models/User.ts]
    dependencies: []
    estimated: 30 分钟

  - unit-2: 实现认证服务
    files: [services/auth.ts]
    dependencies: [unit-1]
    estimated: 1 小时

  - unit-3: 实现 API 路由
    files: [routes/auth.ts]
    dependencies: [unit-2]
    estimated: 45 分钟

  - unit-4: 编写测试
    files: [tests/auth.test.ts]
    dependencies: [unit-1, unit-2, unit-3]
    estimated: 30 分钟
```

#### 示例 2: Bug 修复

```yaml
任务: 修复登录超时问题

拆解结果:
  - unit-1: 分析根因
    files: [services/auth.ts, config/app.ts]
    dependencies: []
    estimated: 15 分钟

  - unit-2: 修复问题
    files: [services/auth.ts]
    dependencies: [unit-1]
    estimated: 30 分钟

  - unit-3: 添加测试
    files: [tests/auth.test.ts]
    dependencies: [unit-2]
    estimated: 15 分钟
```

#### 示例 3: 多文件重构

```yaml
任务: 重构数据访问层

拆解结果:
  - unit-1: 重构用户数据访问
    files: [dal/user.ts]
    dependencies: []
    estimated: 1 小时

  - unit-2: 重构产品数据访问
    files: [dal/product.ts]
    dependencies: []
    estimated: 1 小时

  - unit-3: 重构订单数据访问
    files: [dal/order.ts]
    dependencies: []
    estimated: 1 小时

  # 以上三个单元可以并行执行（无文件冲突）
```

---

## 三、并行调度建议

### 3.1 分层执行

```yaml
基于依赖关系分层:
  - 第 1 层: 无依赖的单元，可并行
  - 第 2 层: 依赖第 1 层的单元
  - 第 3 层: 依赖第 2 层的单元

输出:
  第 1 层 (并发): unit-1, unit-2
  第 2 层 (等待): unit-3
```

### 3.2 文件冲突检测

```yaml
冲突规则:
  - 两个单元涉及相同文件 → 冲突
  - 冲突单元必须顺序执行

示例:
  unit-1: files=[a.ts, b.ts]
  unit-2: files=[c.ts]       # 无冲突，可并行
  unit-3: files=[b.ts, d.ts] # 与 unit-1 冲突，需等待
```

### 3.3 执行命令生成

```yaml
生成 /wolf-pack 命令:

/wolf-pack unit-1 unit-2 unit-3

或分层执行:
/wolf-pack unit-1 unit-2  # 第 1 层
# 等待完成
/wolf-pack unit-3         # 第 2 层
```

---

## 四、优先级规则

```yaml
自动评分:
  🔴 HIGH (80-100):
    - 阻塞问题
    - 安全漏洞
    - 数据丢失风险
    - 用户明确标记重要

  🟡 MEDIUM (40-79):
    - 功能需求
    - 重构任务
    - 性能优化
    - 默认优先级

  🟢 LOW (0-39):
    - 文档更新
    - 样式调整
    - nice-to-have
    - 用户明确标记低优先级
```

---

## 五、展示格式

### 5.1 任务看板

```markdown
═════════════════════════════════════════════════════
  📋 Wolf Task Board
═════════════════════════════════════════════════════

📍 按优先级排序 (高 → 低)
─────────────────────────────────────────────────────

  [1] 🔴 HIGH    - 修复登录超时问题
       来源: issues
       预估: 30 分钟
       描述: 用户报告登录时经常超时

  [2] 🔴 HIGH    - 更新依赖版本
       来源: projects
       预估: 15 分钟
       描述: package.json 中有安全漏洞

  [3] 🟡 MEDIUM  - 实现用户头像功能
       来源: tasks
       预估: 2 小时
       描述: 允许用户上传和显示头像

  [4] 🟡 MEDIUM  - 重构认证模块
       来源: session
       预估: 3 小时
       描述: 从对话中识别的任务

  [5] 🟢 LOW     - 更新 README 文档
       来源: projects
       预估: 20 分钟
       描述: 添加安装说明

─────────────────────────────────────────────────────
统计: 5 个任务 | 预计: 6.5 小时

🔴 HIGH: 2 | 🟡 MEDIUM: 2 | 🟢 LOW: 1

─────────────────────────────────────────────────────
操作:
  - 输入任务编号查看详情
  - 输入 'breakdown' 拆解任务
  - 输入 'exec' 选择后执行
  - 按 Ctrl+C 退出:
```

### 5.2 拆解结果

```markdown
📋 任务拆解结果
════════════════════════════════════

任务: 实现用户认证模块

拆解为 4 个执行单元:

  [1] auth-model
      描述: 定义用户数据模型和 schema
      文件: models/user.ts, schemas/user.schema.ts
      预估: 30 分钟
      依赖: 无

  [2] auth-service
      描述: 实现认证服务（登录、注册、JWT）
      文件: services/auth.service.ts, utils/jwt.ts
      预估: 1 小时
      依赖: auth-model

  [3] auth-api
      描述: 实现 API 路由和控制器
      文件: api/auth.routes.ts, controllers/auth.controller.ts
      预估: 45 分钟
      依赖: auth-service

  [4] auth-tests
      描述: 编写单元测试和集成测试
      文件: tests/auth.test.ts, tests/auth.integration.test.ts
      预估: 30 分钟
      依赖: auth-model, auth-service, auth-api

════════════════════════════════════

执行计划:
  第 1 层: auth-model (无依赖)
  第 2 层: auth-service (依赖 auth-model)
  第 3 层: auth-api (依赖 auth-service)
  第 4 层: auth-tests (依赖所有)

并发建议:
  - auth-model 可独立执行
  - 其他单元需顺序执行

快速执行:
  /wolf-pack auth-model auth-service auth-api auth-tests

─────────────────────────────────────────────────────
操作:
  - 输入 'exec' 立即执行所有单元
  - 输入 'layer' 分层执行
  - 按 Ctrl+C 返回
```

---

## 六、过滤参数

```yaml
--source:
  tasks: 只显示 Claude 任务
  projects: 只显示项目文件任务
  issues: 只显示问题
  session: 只显示会话任务
  (默认): 全部显示

--priority:
  high: 只显示高优先级
  medium: 只显示中优先级
  low: 只显示低优先级
  (默认): 全部显示

--breakdown:
  拆解任务为执行单元

--exec:
  选择后自动执行
```

---

## 七、与执行集成

### 7.1 匹配工作流

```yaml
任务类型 → 工作流:
  bug/问题 → multi-debug
  功能开发 → feature-dev
  重构 → refactor
  通用 → task-board

自动推荐工作流
```

### 7.2 传递执行单元

```yaml
如果用户选择执行单元:
  - 调用 /wolf-pack
  - 传递单元列表
  - 由 wolf-pack 进行并发调度
```

---

## 八、状态更新

```yaml
任务完成后:
  - 更新任务状态 (已完成)
  - 从活跃列表移除
  - 记录到完成历史

任务失败:
  - 标记为失败
  - 保留在列表中
  - 记录错误信息
```

---

## 九、时间估算

```yaml
预估逻辑:
  - 基于任务描述
  - 参考历史数据
  - 用户可修正

显示格式:
  - X 小时
  - X 分钟
  - 未知
```

---

## 十、多 Agent 协同

### 文件冲突处理

```yaml
工作流声明:
  file_lock: ["path/to/file"]

执行时:
  - 检查文件是否被锁定
  - 获取锁的 agent 先执行
  - 其他 agent 等待或跳过
```

### 依赖关系处理

```yaml
工作流声明:
  depends_on: [step_id_1, step_id_2]

执行时:
  - 分析依赖图
  - 拓扑排序
  - 按顺序执行
```

### 上下文共享

```yaml
task-runner 参数:
  - project_context: 项目上下文
  - task_goal: 任务目标
  - task_dependencies: 依赖信息

所有 subagent 接收相同的项目上下文
```
