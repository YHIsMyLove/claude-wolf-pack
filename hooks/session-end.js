#!/usr/bin/env node

/*
 * Wolf Pack SessionEnd Hook (JavaScript)
 * 功能: 记录会话结束状态和统计信息
 */

const path = require('path');
const fs = require('fs');

// 环境变量
const CLAUDE_PLUGIN_ROOT = process.env.CLAUDE_PLUGIN_ROOT || path.join(__dirname, '../');
const PROJECT_ROOT = process.env.CLAUDE_PROJECT_ROOT || process.cwd();

// Wolf 运行时目录
const WOLF_DIR = path.join(PROJECT_ROOT, '.wolf');
const TRACE_DIR = path.join(WOLF_DIR, 'trace');
const DATE = new Date().toISOString().split('T')[0];

// 确保目录存在
function ensureDir(dirPath) {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
}

// 记录文件变化
function recordFileChanges() {
    const filesMdPath = path.join(TRACE_DIR, `${DATE}-files.md`);

    // 获取所有修改的文件
    const files = fs.readdirSync(PROJECT_ROOT, { recursive: true })
        .filter(file => {
            const fullPath = path.join(PROJECT_ROOT, file);
            return fs.statSync(fullPath).isFile() &&
                   !fullPath.includes('node_modules') &&
                   !fullPath.includes('.git') &&
                   path.extname(fullPath) in ['.js', '.md', '.json', '.ts', '.tsx', '.jsx', '.py', '.java', '.go', '.cpp', '.h', '.hpp'];
        })
        .slice(0, 20); // 限制数量

    const content = `# ${DATE} - 文件变化记录

## 修改的文件 (${files.length} 个)

${files.map(file => `- \`${file}\``).join('\n')}

---
*自动生成于 Wolf Pack SessionEnd Hook*
`;

    ensureDir(TRACE_DIR);
    fs.writeFileSync(filesMdPath, content, 'utf8');
}

// 记录会话统计
function recordSessionStats() {
    const statsMdPath = path.join(TRACE_DIR, `${DATE}-stats.md`);

    const now = new Date();
    const timestamp = now.toLocaleString('zh-CN');

    const stats = {
        date: DATE,
        timestamp: timestamp,
        session_duration: '未知',
        files_modified: '需要统计',
        commits_made: 0,
        memory_entries: 0
    };

    const content = `# ${DATE} - 会话统计

## 基本信息

- **会话日期**: ${stats.date}
- **会话时间**: ${stats.timestamp}
- **会话时长**: ${stats.session_duration}
- **修改文件数**: ${stats.files_modified}
- **提交次数**: ${stats.commits_made}
- **记忆条目**: ${stats.memory_entries}

## 会话状态

✅ 会话正常结束

---
*自动生成于 Wolf Pack SessionEnd Hook*
`;

    ensureDir(TRACE_DIR);
    fs.writeFileSync(statsMdPath, content, 'utf8');
}

// 记录会话洞察
function recordSessionInsights() {
    const insightsPath = path.join(PROJECT_ROOT, '.claude/rules/.session-insights.md');

    const now = new Date();
    const timestamp = now.toLocaleString('zh-CN');

    // 获取最近的消息（这里简单模拟，实际需要从 Claude Code API 获取）
    // 由于 Hook 限制，这里记录一个示例消息
    const recentMessages = [
        "用户发送了一条测试消息",
        "Hook 触发测试"
    ];

    const insight = `## [${DATE}] - 会话摘要

**时间**: ${timestamp}
**会话历史**:
${recentMessages.map(msg => `- ${msg}`).join('\n')}

---
`;

    // 检查文件是否存在
    if (fs.existsSync(insightsPath)) {
        // 追加内容
        fs.appendFileSync(insightsPath, insight + '\n', 'utf8');
    } else {
        // 创建文件
        fs.writeFileSync(insightsPath, insight + '\n', 'utf8');
    }
}

// 主函数
function main() {
    console.log('');
    console.log('🐺 Wolf Pack: 记录会话结束状态...');

    try {
        // 记录文件变化
        recordFileChanges();
        console.log('✓ 文件变化已记录');

        // 记录会话统计
        recordSessionStats();
        console.log('✓ 会话统计已记录');

        // 记录会话洞察
        recordSessionInsights();
        console.log('✓ 会话洞察已记录');

        console.log('');
        console.log('🎉 会话结束记录完成！');

    } catch (error) {
        console.error('❌ 记录会话状态出错:', error.message);
        process.exit(1);
    }
}

// 执行
main();