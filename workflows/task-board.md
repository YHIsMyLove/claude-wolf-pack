## Task Board - 任务看板工作流

### 描述
从任务看板选择任务并执行，支持多任务并发处理。

### 触发条件
- 用户从看板选择任务
- 需要批量处理任务
- 任务优先级已确定

### 前置条件 (preconditions)

```yaml
checks:
  - name: tasks_loaded
    description: 任务已加载到看板
    weight: 20
  - name: task_selected
    description: 用户已选择任务
    weight: 20
  - name: workflow_matched
    description: 已匹配合适的工作流
    weight: 15

threshold: 35

destructive: []
```

### 执行配置
- **模式**: lenient
- **偏差处理**: track

### 步骤

#### Step 1: 加载任务

- **关键**: true
- **依赖**: []
- **Agent**: loader
- **并行**: false
- **输出**: 任务列表
- **验收**: 所有所需任务已加载

**任务**: 从多个来源加载任务到看板。

**任务来源**:
- `~/.claude/tasks/` - Claude 内置任务
- `TODO.md`, `TASKS.md` - 项目文件
- `rules/issues.md` - 未解决问题
- 当前会话 - 识别的任务

---

#### Step 2: 任务分类

- **关键**: true
- **依赖**: [1]
- **Agent**: classifier
- **并行**: false
- **输出**: 分类任务列表
- **验收**: 每个任务已分类

**任务**: 按类型和优先级分类任务。

**分类维度**:
- 类型: bug | feature | refactor | doc | other
- 优先级: high | medium | low
- 复杂度: simple | medium | complex

---

#### Step 3: 匹配工作流

- **关键**: true
- **依赖**: [2]
- **Agent**: matcher
- **并行**: false
- **输出**: 工作流映射
- **验收**: 每个任务有推荐工作流

**任务**: 为每个任务匹配合适的工作流。

**映射规则**:
```yaml
bug → multi-debug
feature → feature-dev
refactor → refactor
doc → simple-edit
other → generic-task
```

---

#### Step 4: 用户选择

- **关键**: true
- **依赖**: [3]
- **Agent**: none (主对话)
- **并行**: false
- **输出**: 选中的任务
- **验收**: 用户确认选择

**任务**: 展示看板，等待用户选择。

**看板格式**:
```
═════════════════════════════════════════════════════
  📋 Wolf Task Board
═════════════════════════════════════════════════════

📍 按优先级排序 (高 → 低)
─────────────────────────────────────────────────────

  [1] 🔴 HIGH    - [任务标题]
       类型: bug | 工作流: multi-debug
       预估: 30 分钟

  [2] 🟡 MEDIUM  - [任务标题]
       类型: feature | 工作流: feature-dev
       预估: 2 小时

─────────────────────────────────────────────────────
选择任务编号 (逗号分隔多个):
```

---

#### Step 5: 执行任务 (并行: 是)

- **关键**: true
- **依赖**: [4]
- **Agent**: executor (多个并发)
- **并行**: true
- **输出**: 执行结果
- **验收**: 所选任务已处理

**任务**: 为每个选中的任务启动对应的执行流程。

**执行策略**:
- 独立任务: 并发执行
- 有依赖任务: 顺序执行
- 冲突任务: 等待锁释放

**Agent 任务模板**:
```
执行以下任务：

任务: {{TASK_DESCRIPTION}}
类型: {{TASK_TYPE}}
工作流: {{WORKFLOW_NAME}}

使用 {{WORKFLOW_NAME}} 工作流执行此任务。
```

---

#### Step 6: 结果汇总

- **关键**: true
- **依赖**: [5]
- **Agent**: summarizer
- **并行**: false
- **输出**: 执行报告
- **验收**: 所有结果已汇总

**任务**: 汇总所有任务的执行结果。

**报告内容**:
- 完成任务列表
- 失败任务及原因
- 总耗时
- 后续建议

---

#### Step 7: 更新状态

- **关键**: false
- **依赖**: [6]
- **Agent**: updater
- **并行**: false
- **输出**: 更新后的任务文件
- **验收**: 任务状态已同步

**任务**: 更新任务源文件的状态。

**更新位置**:
- `~/.claude/tasks/` - 标记完成
- `TODO.md` - 更新复选框
- `rules/issues.md` - 更新状态

---

## 并发控制

### 文件锁机制

```yaml
冲突检测:
  - 任务声明 file_lock
  - 执行前检查锁状态
  - 获取锁后执行

锁释放:
  - 任务完成自动释放
  - 任务失败自动释放
  - 超时自动释放
```

### 依赖处理

```yaml
依赖声明:
  depends_on: [task_id_1, task_id_2]

执行顺序:
  1. 分析依赖图
  2. 拓扑排序
  3. 按顺序执行
```

---

## 示例使用场景

```yaml
场景: 批量处理 bug 修复

Step 1: 加载任务
  → 从 issues.md 加载 5 个问题
  → 从 TODO.md 加载 3 个任务

Step 2: 分类
  → Bug: 4 个
  → Feature: 2 个
  → Doc: 2 个

Step 3: 匹配工作流
  → Bug → multi-debug
  → Feature → feature-dev

Step 4: 用户选择
  → 选择 1, 2, 3 (三个 bug)

Step 5: 并发执行
  → Agent 1: 处理 bug 1
  → Agent 2: 处理 bug 2
  → Agent 3: 处理 bug 3

Step 6: 汇总
  → 完成 3 个 bug
  → 失败 0 个

Step 7: 更新
  → 更新 issues.md 状态
```
