---
name: wolf-brainstorm
description: 通过交互式提问澄清目标和验收标准
---

# Wolf Brainstorm 头脑风暴技能

## 功能

通过 `AskUserQuestion` 工具系统化提问澄清用户目标：

1. **目标澄清** - 多轮提问确保目标清晰
2. **清晰度评估** - 量化评估目标明确程度
3. **摘要生成** - 基于目标生成可执行计划摘要
4. **决策记录** - 自动记录到项目记忆

---

## 交互流程

```
开始
  ↓
AskUserQuestion: 目标问题 (第1层)
  ↓
AskUserQuestion: 约束问题 (第2层) [multiSelect: true]
  ↓
AskUserQuestion: 验收问题 (第3层)
  ↓
计算清晰度评分
  ↓
评分 >= 64?
  YES → AskUserQuestion: 确认摘要
  NO  → AskUserQuestion: 是否继续提问
```

---

## 提问模板

### 第一层：核心目标

```yaml
AskUserQuestion:
  questions:
    - question: "你想要完成什么？请简要描述你的目标。"
      header: "核心目标"
      options:
        - label: "开发新功能"
        - label: "修复 Bug"
        - label: "重构代码"
        - label: "其他"
      multiSelect: false
```

### 第二层：约束条件

```yaml
AskUserQuestion:
  questions:
    - question: "有哪些约束条件？（可多选）"
      header: "约束条件"
      options:
        - label: "时间限制"
        - label: "技术限制"
        - label: "性能要求"
        - label: "无特殊约束"
      multiSelect: true
```

### 第三层：验收标准

```yaml
AskUserQuestion:
  questions:
    - question: "如何判断目标已完成？"
      header: "验收标准"
      options:
        - label: "功能验证"
        - label: "性能指标"
        - label: "代码审查"
        - label: "自定义"
      multiSelect: true
```

### 摘要确认

```yaml
AskUserQuestion:
  questions:
    - question: |
        请确认以下计划摘要：
        **目标**: {目标摘要}
        **验收**: {验收标准}
        **约束**: {约束条件}
        **预估**: {预估时间}
      header: "确认计划"
      options:
        - label: "确认并记录"
        - label: "需要修改"
      multiSelect: false
```

---

## 清晰度评分逻辑

```yaml
目标明确 (0-20分): 选择了具体选项 + 详细描述
背景清晰 (0-20分): 提到了原因/背景 + 上下文
约束明确 (0-20分): 选择了约束选项 + 多选
验收可验证 (0-20分): 选择了验证方式 + 多选

总分 >= 64: 清晰，可生成摘要
总分 48-63: 基本清晰，建议补充
总分 < 48: 不够清晰，继续提问
```

---

## 执行集成

```yaml
用户选择 "确认并记录" 后:

1. 记录决策: /wolf-memory save decision
2. 询问是否拆分任务
3. 如确认拆分: 调用 /wolf-board --breakdown --save
```

---

## 技能调用示例

```bash
# 基础调用
/wolf-brainstorm

# 与工作流集成
/wolf-brainstorm  # 澄清目标
/wolf-pack feature-dev  # 执行开发
```
