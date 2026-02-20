---
name: wolf-board
description: 汇总任务并拆解为可并行执行的单元
---

# Wolf Board 任务看板与拆解技能

## 功能

1. **多源聚合** - 扫描不同来源的任务
2. **优先级排序** - 按重要性排序
3. **任务拆解** - 将任务拆解为可并行的执行单元
4. **执行集成** - 选择后自动执行工作流或并行调度

---

## 一、任务来源扫描

```yaml
路径与优先级:
  ~/.claude/tasks/          # Claude 内置任务 → MEDIUM
  TODO.md, TASKS.md         # 项目文件任务 → 按标记
  rules/issues.md           # 记忆中的问题 → HIGH
  对话历史                  # 当前会话任务 → MEDIUM
```

**Markdown 任务格式**:
```markdown
- [ ] 任务描述          → LOW
- [!] 重要: 任务描述    → HIGH
- [-] 进行中任务        → MEDIUM
```

---

## 二、任务拆解

### 2.1 拆解原则

```yaml
按文件边界拆分 (避免冲突)
按功能模块拆分 (高内聚)
按依赖关系排序
```

### 2.2 拆解算法

```yaml
步骤 1: 分析任务类型
  - bug/问题 → 按文件拆分
  - 功能开发 → 按模块拆分
  - 重构 → 按影响范围拆分

步骤 2: 识别涉及文件
步骤 3: 构建依赖图
步骤 4: 生成执行单元
```

### 2.3 拆解示例

```yaml
任务: 实现用户认证功能

拆解结果:
  TaskCreate("定义用户模型", "创建 User 数据模型和 schema", "定义用户模型")
  TaskCreate("实现认证服务", "实现登录、注册、JWT 功能", "实现认证服务")
  TaskCreate("实现 API 路由", "创建认证相关的 API 端点", "实现 API 路由")
  TaskCreate("编写测试", "编写单元测试和集成测试", "编写测试")

  # 设置依赖关系
  TaskUpdate(taskId_2, addBlockedBy=[taskId_1])
  TaskUpdate(taskId_3, addBlockedBy=[taskId_2])
  TaskUpdate(taskId_4, addBlockedBy=[taskId_1, taskId_2, taskId_3])
```

---

## 三、并行调度建议

### 3.1 分层执行

```yaml
基于依赖关系分层:
  第 1 层: 无依赖的单元，可并行
  第 2 层: 依赖第 1 层的单元
  第 3 层: 依赖第 2 层的单元

输出:
  第 1 层 (并发): task-1, task-2
  第 2 层 (等待): task-3
```

### 3.2 执行命令生成

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
  HIGH (80-100): 阻塞问题、安全漏洞、数据丢失风险
  MEDIUM (40-79): 功能需求、重构任务、性能优化
  LOW (0-39): 文档更新、样式调整、nice-to-have
```

---

## 五、展示格式

### 5.1 任务看板

```markdown
═════════════════════════════════════════════════════
  📋 Wolf Task Board
═════════════════════════════════════════════════════

  [1] HIGH   - 修复登录超时问题 (30分钟)
  [2] HIGH   - 更新依赖版本 (15分钟)
  [3] MEDIUM - 实现用户头像功能 (2小时)
  [4] MEDIUM - 重构认证模块 (3小时)
  [5] LOW    - 更新 README 文档 (20分钟)

═════════════════════════════════════════════════════
统计: 5 个任务 | 预计: 6.5 小时
```

### 5.2 拆解结果输出

拆解完成后直接输出 TaskCreate 调用格式:

```markdown
TaskCreate("定义用户模型", "创建 User 数据模型和 schema", "定义用户模型")
TaskCreate("实现认证服务", "实现登录、注册、JWT 功能", "实现认证服务")
TaskCreate("实现 API 路由", "创建认证相关的 API 端点", "实现 API 路由")

# 依赖关系由 blockedBy 自动处理
```

---

## 六、任务存储

```yaml
默认路径: .wolf/tasks/
文件命名: YYYY-MM-DD-{slug}.units.md
存储触发: --save 参数确认后
```

---

## 七、与 wolf-brainstorm 集成

```yaml
输入: 目标、验收、约束、预估时间
输出: TaskCreate 调用列表 + 存储路径

确认后输出:
  TaskCreate(...)
  TaskUpdate(..., addBlockedBy=[...])
```
