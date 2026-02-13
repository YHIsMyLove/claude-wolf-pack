---
argument-hint: <action> [args...]
description: 多层记忆管理系统 - 记录、加载、搜索项目记忆
---

# Wolf Memory - 多层记忆管理系统

## 用法

### 基本用法

```
/wolf-memory save issue [描述]           # 记录问题
/wolf-memory save decision [描述]        # 记录决策
/wolf-memory save pattern [描述]         # 记录模式
/wolf-memory save context [内容]          # 更新上下文
```

### 加载记忆

```
/wolf-memory load [id]                   # 按 ID 加载
/wolf-memory load --tag=typescript         # 按标签
/wolf-memory load --category=decisions    # 按类别
```

### 管理记忆

```
/wolf-memory search [keyword]              # 搜索记忆
/wolf-memory update-index                 # 更新索引
```

### 初始化

```
/wolf-memory init                         # 初始化记忆目录
```

---

## 记忆层级

```
L0: ~/.claude/CLAUDE.md              # 全局指令（Claude 自动加载）
L1: .wolf.md                          # 项目入口索引
L2: .wolf/memory/                     # 二级记忆（按需加载）
    ├── index.md                        # 主索引
    ├── decisions/                        # 决策记忆
    ├── patterns/                         # 模式记忆
    ├── issues/                           # 问题记忆
    ├── context/                          # 上下文记忆
    └── archived/                         # 归档记忆
```

---

## 快捷命令

```
/wolf-memory save i "登录失败"            # 快速记录问题
/wolf-memory save d "使用 TypeScript"       # 快速记录决策
/wolf-memory save p "函数式组件"           # 快速记录模式
```

---

**此命令调用 `wolf-memory` 技能执行实际操作。**

详细文档请参考技能定义文件。
