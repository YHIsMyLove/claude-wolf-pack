#!/usr/bin/env node

/*
 * Wolf Pack 记忆提升脚本
 * 功能：将优质项目记忆提升到用户级记忆系统
 */

const path = require('path');
const fs = require('fs');
const yaml = require('js-yaml');

// 配置
const PROJECT_ROOT = process.cwd();
const USER_MEMORY_DIR = path.join(process.env.HOME || process.env.USERPROFILE, '.claude', 'rules');
const PROJECT_MEMORY_DIR = path.join(PROJECT_ROOT, '.claude', 'rules');
const CONFIG_PATH = path.join(PROJECT_MEMORY_DIR, 'issues', 'config.yaml');

// 提升条件
const PROMOTION_CRITERIA = {
    decisions: {
        priority: 'high',
        minProjects: 2,
        age: 30 // 天数
    },
    patterns: {
        reusability: 'high',
        usages: 3,
        score: 8
    },
    issues: {
        solutionScore: 9,
        recurrence: 2,
        impact: 'high'
    }
};

// 主要功能
function promoteMemory() {
    console.log('🔄 开始记忆提升检查...');

    // 确保用户记忆目录存在
    ensureUserMemoryDir();

    // 检查项目记忆
    const decisions = checkDecisions();
    const patterns = checkPatterns();
    const issues = checkIssues();

    // 显示结果
    displayResults(decisions, patterns, issues);

    // 执行提升
    if (hasContentToPromote(decisions, patterns, issues)) {
        performPromotion(decisions, patterns, issues);
    }
}

// 确保用户记忆目录
function ensureUserMemoryDir() {
    if (!fs.existsSync(USER_MEMORY_DIR)) {
        fs.mkdirSync(USER_MEMORY_DIR, { recursive: true });
    }

    // 创建子目录
    const subdirs = ['decisions', 'patterns', 'issues', 'context', 'archived'];
    subdirs.forEach(subdir => {
        const dir = path.join(USER_MEMORY_DIR, subdir);
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir, { recursive: true });
        }
    });
}

// 检查决策记录
function checkDecisions() {
    const decisions = [];
    const decisionsDir = path.join(PROJECT_MEMORY_DIR, 'decisions');

    if (!fs.existsSync(decisionsDir)) {
        return decisions;
    }

    const files = fs.readdirSync(decisionsDir);
    files.forEach(file => {
        if (file.endsWith('.md')) {
            const filePath = path.join(decisionsDir, file);
            const content = fs.readFileSync(filePath, 'utf8');

            // 解析 frontmatter
            const frontmatter = parseFrontmatter(content);
            if (frontmatter && frontmatter.priority === 'high') {
                decisions.push({
                    id: frontmatter.id,
                    path: filePath,
                    title: extractTitle(content),
                    frontmatter: frontmatter
                });
            }
        }
    });

    return decisions;
}

// 检查模式记录
function checkPatterns() {
    const patterns = [];
    const patternsDir = path.join(PROJECT_MEMORY_DIR, 'patterns');

    if (!fs.existsSync(patternsDir)) {
        return patterns;
    }

    // 检查所有子目录
    const categories = fs.readdirSync(patternsDir);
    categories.forEach(category => {
        const categoryDir = path.join(patternsDir, category);
        if (fs.statSync(categoryDir).isDirectory()) {
            const files = fs.readdirSync(categoryDir);
            files.forEach(file => {
                if (file.endsWith('.md')) {
                    const filePath = path.join(categoryDir, file);
                    const content = fs.readFileSync(filePath, 'utf8');

                    const frontmatter = parseFrontmatter(content);
                    if (frontmatter && frontmatter.reusability === 'high') {
                        patterns.push({
                            id: frontmatter.id,
                            path: filePath,
                            title: extractTitle(content),
                            category: category,
                            frontmatter: frontmatter
                        });
                    }
                }
            });
        }
    });

    return patterns;
}

// 检查问题记录
function checkIssues() {
    const issues = [];
    const issuesDir = path.join(PROJECT_MEMORY_DIR, 'issues', 'solved');

    if (!fs.existsSync(issuesDir)) {
        return issues;
    }

    const files = fs.readdirSync(issuesDir);
    files.forEach(file => {
        if (file.endsWith('.md')) {
            const filePath = path.join(issuesDir, file);
            const content = fs.readFileSync(filePath, 'utf8');

            // 检查解决方案评分
            const solutionScore = extractSolutionScore(content);
            if (solutionScore >= 9) {
                issues.push({
                    id: extractIssueId(content),
                    path: filePath,
                    title: extractTitle(content),
                    solutionScore: solutionScore,
                    content: content
                });
            }
        }
    });

    return issues;
}

// 解析 frontmatter
function parseFrontmatter(content) {
    const match = content.match(/^---\s*\n([\s\S]*?)\n---\s*\n/);
    if (!match) return null;

    try {
        return yaml.load(match[1]);
    } catch (e) {
        return null;
    }
}

// 提取标题
function extractTitle(content) {
    const match = content.match(/^#\s+(.+)$/m);
    return match ? match[1] : '无标题';
}

// 提取问题ID
function extractIssueId(content) {
    const match = content.match(/^##\s+\d{4}-\d{2}-\d{2}\s+-\s+(.+)$/m);
    return match ? match[1] : 'unknown';
}

// 提取解决方案评分
function extractSolutionScore(content) {
    const match = content.match(/\*\*解决方案评分\*\*:\s*\[(\d+)\]/);
    return match ? parseInt(match[1]) : 0;
}

// 显示结果
function displayResults(decisions, patterns, issues) {
    console.log('\n📊 记忆检查结果:');
    console.log(`决策记录: ${decisions.length} 个可提升`);
    console.log(`模式记录: ${patterns.length} 个可提升`);
    console.log(`问题记录: ${issues.length} 个可提升`);

    if (decisions.length > 0) {
        console.log('\n🎯 可提升的决策:');
        decisions.forEach(d => {
            console.log(`  - ${d.title} (ID: ${d.id})`);
        });
    }

    if (patterns.length > 0) {
        console.log('\n🔧 可提升的模式:');
        patterns.forEach(p => {
            console.log(`  - ${p.title} [${p.category}] (ID: ${p.id})`);
        });
    }

    if (issues.length > 0) {
        console.log('\n✅ 可提升的问题解决方案:');
        issues.forEach(i => {
            console.log(`  - ${i.title} (评分: ${i.solutionScore}/10)`);
        });
    }
}

// 检查是否有内容可提升
function hasContentToPromote(decisions, patterns, issues) {
    return decisions.length > 0 || patterns.length > 0 || issues.length > 0;
}

// 执行提升
function performPromotion(decisions, patterns, issues) {
    console.log('\n🚀 开始执行记忆提升...');

    const promoted = [];

    // 提升决策
    decisions.forEach(decision => {
        const destPath = path.join(USER_MEMORY_DIR, 'decisions', `${decision.id}.md`);
        copyFile(decision.path, destPath);
        promoted.push(`决策: ${decision.title}`);
    });

    // 提升模式
    patterns.forEach(pattern => {
        const destPath = path.join(USER_MEMORY_DIR, 'patterns', pattern.category, `${pattern.id}.md`);
        ensureDirectoryExists(path.dirname(destPath));
        copyFile(pattern.path, destPath);
        promoted.push(`模式: ${pattern.title} [${pattern.category}]`);
    });

    // 提升问题解决方案
    issues.forEach(issue => {
        const destPath = path.join(USER_MEMORY_DIR, 'issues', 'solved', `${issue.id}.md`);
        copyFile(issue.path, destPath);
        promoted.push(`问题: ${issue.title}`);
    });

    console.log('\n✅ 记忆提升完成:');
    promoted.forEach(item => {
        console.log(`  ✓ ${item}`);
    });
}

// 确保目录存在
function ensureDirectoryExists(dir) {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
}

// 复制文件
function copyFile(src, dest) {
    fs.copyFileSync(src, dest);
}

// 添加时间戳
function addTimestamp(content) {
    const timestamp = new Date().toISOString().split('T')[0];
    return content + `\n\n---\n\n*此记忆于 ${timestamp} 从项目级提升到用户级*`;
}

// 主执行
if (require.main === module) {
    promoteMemory();
}

module.exports = { promoteMemory, PROMOTION_CRITERIA };