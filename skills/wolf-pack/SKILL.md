---
name: wolf-pack
description: 执行工作流、管理工作流模板、并行执行单元
---

# Wolf Pack 工作流执行与调度技能

## 功能

此技能负责：

1. **工作流执行** - 执行预定义的工作流模板
2. **工作流管理** - 创建、列表、验证工作流（原 wolf-flow）
3. **并行调度** - 并发执行多个执行单元
4. **前置条件检查** - 加权评分验证
5. **多 Agent 并发** - 使用 Task 工具并发执行

---

## 一、工作流执行

### 1.1 加载工作流

```yaml
从 workflows/{{workflow_name}}.md 读取工作流定义
解析: 触发条件、前置条件、破坏性操作、执行步骤
```

### 1.2 前置条件检查

```yaml
对每个 check:
  - 执行检查逻辑
  - 按权重评分 (0-20)
  - 记录通过/失败状态

计算总分 = 各项权重之和
验证: 总分 >= threshold ?
  通过: 继续
  失败: 中止执行，输出检查报告
```

### 1.3 破坏性操作确认

```yaml
如果工作流包含破坏性操作:
  - 列出所有破坏性操作
  - 要求用户确认 (除非 --force)
  - 用户取消则中止
```

### 1.4 执行步骤

```yaml
按步骤定义:
  - 分析步骤依赖关系
  - 构建执行计划 (并发/顺序)
  - 启动 subagent(s)

使用 Task 工具:
  - 并发步骤: 同时启动多个 agent
  - 顺序步骤: 等待前一步完成
  - 收集每个 agent 的输出
```

### 1.5 结果整合

```yaml
收集所有 subagent 输出:
  - 整合结果
  - 验证完成度
  - 生成执行报告
```

---

## 六、头脑风暴集成（来自 wolf-brainstorm）

### 6.1 调用条件

当用户执行 `/wolf-brainstorm` 并确认目标摘要后：
- 目标已清晰（评分 >= 64）
- 验收标准已明确
- 约束已识别

### 6.2 自动传递

```
📋 计划摘要
─────────────────────────────

目标: [一句话目标]
验收: [验收标准]
约束: [主要约束]
预估: [X] 小时

接收？(y/n)
```

确认后自动：
1. 调用 `/wolf-board` - 将摘要作为新任务添加到看板
2. 调用 `/wolf-pack` - 传递给对应工作流

### 6.3 工作流匹配

```yaml
目标类型 → 推荐工作流:
  头杂功能开发 → feature-dev
  多问题并行 → multi-debug
  代码重构 → refactor
  任务看板 → task-board
 通用任务 → task-board
```

---

## 二、工作流管理（原 wolf-flow）

### 2.1 create - 创建工作流

```yaml
交互式流程:
  1. 询问工作流名称
  2. 询问描述
  3. 询问触发条件
  4. 询问是否需要前置条件
  5. 添加步骤 (循环)
  6. 确认并保存

输出:
  - 工作流文件路径
  - 使用说明
```

### 2.2 list - 列出工作流

```yaml
输出格式:
  📋 可用工作流

  [1] multi-debug
      描述: 多问题并行调试
      步骤: 4 | 前置条件: 5

  [2] feature-dev
      描述: 完整功能开发流程
      步骤: 5 | 前置条件: 3

  ...

  共 N 个工作流
```

### 2.3 validate - 验证工作流

```yaml
检查项:
  ✓ 结构完整性
  ✓ 步骤依赖有效性
  ✓ 前置条件权重合理性
  ✓ Agent 引用有效性
  ✓ 验收标准清晰性

输出:
  通过 → ✓ 工作流有效
  失败 → ✗ 问题列表
```

### 2.4 工作流格式

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
  - name: project_clean
    description: 项目状态干净（无未提交更改）
    weight: 15
  - name: tests_passing
    description: 核心测试套件通过
    weight: 20
  - name: config_files_exist
    description: 配置文件存在
    weight: 10
  - name: environment_ready
    description: 环境就绪（服务可用、资源充足）
    weight: 15

threshold: 60

destructive:
  - delete_files: true
  - overwrite_code: true
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

## 三、并行执行单元

### 3.1 执行单元数据结构

```yaml
ExecUnit:
  id: string                  # 唯一标识
  description: string          # 描述
  files: string[]              # 涉及文件
  dependencies: string[]       # 依赖的 unit id
  estimated_time: string       # 预估时间
  priority: high|medium|low    # 优先级
  agent_type: string           # agent 类型
```

### 3.2 并行调度逻辑

```yaml
输入: 执行单元列表 [unit1, unit2, ...]

步骤:
  1. 构建依赖图
  2. 检测文件冲突
  3. 分层执行 (拓扑排序)
  4. 并发启动同层 agent
  5. 收集结果

文件冲突处理:
  - 检查 files 是否重叠
  - 重叠文件: 顺序执行
  - 无重叠: 并发执行
```

### 3.3 调度示例

```yaml
输入单元:
  - unit1: files=[a.ts, b.ts]
  - unit2: files=[c.ts, d.ts]
  - unit3: files=[b.ts, e.ts]  # 与 unit1 冲突

调度结果:
  第 1 层 (并发): unit1, unit2
  第 2 层 (等待): unit3 (依赖 unit1 完成)
```

---

## 四、Subagent 调用

```yaml
Agent 模板:
  subagent_type: "general-purpose"
  prompt: |
    你是一个任务执行专家。

    **任务**: {{step_task}}
    **上下文**: {{project_context}}
    **目标**: {{step_goal}}
    **验收标准**: {{step_acceptance}}

    请执行任务并返回:
    1. 执行内容描述
    2. 修改的文件列表
    3. 验证方法
```

---

## 五、错误处理

```yaml
前置条件失败:
  - 输出检查报告
  - 建议修复方法
  - 中止执行

步骤执行失败:
  - 记录错误信息
  - 根据 mode 决定: 继续/中止
  - strict: 任何失败都中止
  - lenient: 关键步骤失败才中止
```

---

## 六、输出格式

### 执行报告

```markdown
## 执行报告

### 前置条件检查
✅ dependencies_installed: 10/10
✅ project_clean: 15/15
⚠️  tests_passing: 5/20 (部分测试失败)
✅ config_files_exist: 10/10
❌ environment_ready: 0/15 (服务未启动)

**总分**: 40/60
**结果**: 未达到阈值，中止执行

建议:
- 启动所需服务
- 修复失败的测试
```

### 并行执行报告

```markdown
## 并行执行报告

### 执行计划
第 1 层 (并发): unit1, unit2, unit4
第 2 层 (等待): unit3

### 执行结果
✅ unit1: 完成 (耗时 2 分钟)
✅ unit2: 完成 (耗时 1.5 分钟)
✅ unit4: 完成 (耗时 3 分钟)
✅ unit3: 完成 (耗时 1 分钟)

### 修改文件
- path/to/file1.ts
- path/to/file2.ts
- path/to/file3.ts

**总计**: 4/4 完成，耗时 3 分钟
```

---

## 七、工作流模式

### strict 模式
- 所有步骤必须执行
- 任何失败都中止
- 用于关键功能开发

### lenient 模式
- 关键步骤必须完成
- 可选步骤可跳过
- 用于探索性任务

## 偏差处理

### track 模式
- 记录所有偏差
- 继续执行
- 最后输出偏差报告

### block 模式
- 偏差时立即停止
- 要求用户决策
- 用于危险操作

### warn 模式
- 偏差时警告
- 继续执行
- 用于非关键操作

---

## 八、验证规则

### 结构检查

```yaml
必需部分:
  - 描述: 不能为空
  - 触发条件: 不能为空
  - 步骤: 至少 1 个

可选部分:
  - 前置条件: 如有，必须有效
  - 执行配置: 默认 strict + track
```

### 步骤检查

```yaml
必需字段:
  - 标题: 不能为空
  - 描述: 不能为空

可选字段:
  - 关键: 默认 true
  - 依赖: 必须引用有效步骤
  - Agent: 默认 general-purpose
  - 并行: 默认 false
  - 验收: 默认 "手动确认"

依赖验证:
  - 步骤编号必须存在
  - 不能循环依赖
```

### 前置条件检查

```yaml
权重规则:
  - 单项权重: 0-20
  - 阈值: 0-100
  - 建议阈值: 总权重的 60-80%

破坏性操作:
  - 至少有一个时需要用户确认
```

---

## 九、文件组织

```yaml
workflows/
├── multi-debug.md      # 预定义
├── feature-dev.md      # 预定义
├── refactor.md         # 预定义
├── task-board.md       # 预定义
└── custom/
    ├── my-workflow.md  # 用户自定义
    └── team-flow.md    # 用户自定义
```

---

## 十、快速模板

### basic 模板

```markdown
## [名称]
### 描述
### 触发条件
### 步骤
#### Step 1: [步骤]
#### Step 2: [步骤]
```

### advanced 模板

```markdown
## [名称]
### 描述
### 触发条件
### 前置条件
### 执行配置
### 步骤 (含依赖、验收)
```

### parallel 模板

```markdown
## [名称]
### 描述
### 触发条件
### 步骤 (并行执行)
#### Step 1: [步骤] (并行: 是)
#### Step 2: [步骤] (并行: 是)
#### Step 3: 整合结果
```
