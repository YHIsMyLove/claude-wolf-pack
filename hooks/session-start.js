#!/usr/bin/env node

/*
 * Wolf Pack SessionStart Hook (JavaScript)
 * 功能: 读取项目规则并注入到系统上下文
 */

const path = require('path');
const fs = require('fs');

// 环境变量
const CLAUDE_PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || path.join(__dirname, '../');
const PROJECT_ROOT = process.env.CLAUDE_PROJECT_ROOT || process.cwd();

// 规则目录 - 使用 .claude/rules/ 作为统一记忆系统
const RULES_DIR = path.join(PROJECT_ROOT, '.claude/rules');
const MEMORY_DIR = path.join(PROJECT_ROOT, '.claude/rules');
const WOLF_MD = path.join(PROJECT_ROOT, '.wolf.md');
const MEMORY_INDEX = path.join(MEMORY_DIR, 'index.md');

// 输出标记 (用户可见)
console.log('');
console.log('🐺 Wolf Pack: 加载项目规则...');

// 函数: 安全读取文件
function safeRead(filePath) {
    if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
        const content = fs.readFileSync(filePath, 'utf8');
        if (content && content.trim() !== '') {
            console.log('');
            console.log(`--- ${filePath} ---`);
            console.log(content);
        }
    }
}

// 函数: 列出规则文件
function getRuleFiles() {
    if (fs.existsSync(RULES_DIR)) {
        const files = [];
        const items = fs.readdirSync(RULES_DIR, { recursive: true });

        items.forEach(item => {
            const fullPath = path.join(RULES_DIR, item);
            if (fs.statSync(fullPath).isFile() && path.extname(fullPath) === '.md') {
                files.push(fullPath);
            }
        });

        return files.sort();
    }
    return [];
}

// 函数: 初始化规则目录
function initializeRulesDir() {
    if (!fs.existsSync(RULES_DIR)) {
        fs.mkdirSync(RULES_DIR, { recursive: true });
    }

    // 创建子目录
    const subdirs = ['decisions', 'patterns', 'issues', 'context', 'archived'];
    subdirs.forEach(subdir => {
        const dirPath = path.join(RULES_DIR, subdir);
        if (!fs.existsSync(dirPath)) {
            fs.mkdirSync(dirPath, { recursive: true });
        }

        // 创建 README
        const readme = path.join(dirPath, 'README.md');
        if (!fs.existsSync(readme)) {
            const content = `# ${subdir.charAt(0).toUpperCase() + subdir.slice(1)}\n\n此目录用于记录${subdir}相关内容。\n`;
            fs.writeFileSync(readme, content, 'utf8');
        }
    });

    // 创建 index.md
    const indexPath = path.join(RULES_DIR, 'index.md');
    if (!fs.existsSync(indexPath)) {
        const now = new Date().toISOString().split('T')[0];
        const indexContent = `# Wolf Pack 记忆索引

> 最后更新：${now} | 总计：0 条记忆

## 🔥 热点记忆（Top Priority）

### 决策类
- _暂无决策记录_

### 模式类
- _暂无模式记录_

## 📁 分类统计

| 类别 | 数量 | 最近更新 |
|------|------|----------|
| decisions | 0 | - |
| patterns | 0 | - |
| issues-open | 0 | - |
| issues-solved | 0 | - |

## 🔍 标签云

_暂无标签_

## 📋 待办事项

- _暂无待办事项_

---

## 关于记忆系统

这是 Wolf Pack 插件的多层级记忆系统，用于记录项目决策、模式和问题。

### 记忆类别

- **决策 (decisions/)**: 记录重要技术决策及其理由
- **模式 (patterns/)**: 记录可复用的成功模式和工作流
- **问题 (issues/)**: 记录遇到的问题和解决方案
- **上下文 (context/)**: 项目上下文信息
- **归档 (archived/)**: 已归档的历史记忆
`;
        fs.writeFileSync(indexPath, indexContent, 'utf8');
    }
}

// 主逻辑
function main() {
    let rulesFound = false;

    // 初始化规则目录
    initializeRulesDir();

    // 1. 读取 .wolf.md
    safeRead(WOLF_MD);
    if (fs.existsSync(WOLF_MD)) {
        rulesFound = true;
    }

    // 2. 读取 rules/ 目录
    const ruleFiles = getRuleFiles();
    ruleFiles.forEach(file => {
        safeRead(file);
        rulesFound = true;
    });

    // 3. 加载记忆索引 (L2 记忆)
    safeRead(MEMORY_INDEX);
    if (fs.existsSync(MEMORY_INDEX)) {
        rulesFound = true;
    }

    // 4. 输出状态
    if (!rulesFound) {
        console.log('');
        console.log('ℹ️  项目尚未初始化 Wolf Pack 记忆系统');
        console.log('   使用 /wolf-memory init 可初始化记忆结构');
    } else {
        console.log('');
        console.log('✓ 项目规则已加载');
    }

    console.log('');
}

// 执行
main();