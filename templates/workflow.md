## [工作流名称]

### 描述
[工作流的简短描述，1-2 句话]

### 触发条件
[什么情况下使用此工作流]

### 前置条件 (preconditions)

```yaml
# 工作流前置条件
checks:
  - name: {{check_name_1}}
    description: {{检查项描述}}
    weight: {{权重 0-20}}
  - name: {{check_name_2}}
    description: {{检查项描述}}
    weight: {{权重 0-20}}

# 验收标准 - 总分达到此值才允许执行
threshold: {{阈值 0-100}}

# 破坏性操作 - 涉及以下操作需要用户确认
destructive:
  - delete_files: {{true/false}}
  - overwrite_code: {{true/false}}
  - database_migration: {{true/false}}
  - api_breaking_change: {{true/false}}
```

### 执行配置

- **模式**: `strict` | `lenient`
  - `strict`: 所有步骤必须执行，不得跳过
  - `lenient`: 关键步骤必须完成，可选步骤可跳过

- **偏差处理**: `track` | `block` | `warn`
  - `track`: 记录偏差并继续
  - `block`: 偏差时停止执行
  - `warn`: 偏差时警告但继续

### 步骤

---

#### Step {{N}}: [步骤名称]

- **关键**: {{true/false}}
- **依赖**: {{[前置步骤编号]}}
- **Agent**: {{subagent 名称}}
- **并行**: {{true/false}}
- **输出**: {{预期结果}}
- **验收**: {{如何验证完成}}

**任务**: [步骤详细描述]

**Agent 任务模板**:
```
{{Agent 执行的具体任务内容}}
```

**检查清单**:
- [ ] {{检查项 1}}
- [ ] {{检查项 2}}
- [ ] {{检查项 3}}

---

#### Step {{N+1}}: [步骤名称]

- **关键**: {{true/false}}
- **依赖**: {{[前置步骤编号]}}
- **Agent**: {{subagent 名称}}
- **并行**: {{true/false}}
- **输出**: {{预期结果}}
- **验收**: {{如何验证完成}}

**任务**: [步骤详细描述]

---

## 使用示例

```yaml
场景: {{使用场景描述}}

执行流程:
  Step 1: {{第一步}}
    → {{输出}}

  Step 2: {{第二步}}
    → {{输出}}

  ...
```

## 注意事项

1. {{注意事项 1}}
2. {{注意事项 2}}
3. {{注意事项 3}}

---

*此工作流由 Wolf Pack 插件管理。使用 `/wolf-flow` 命令创建或编辑工作流。*
