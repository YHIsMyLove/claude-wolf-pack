#!/usr/bin/env node

/*
 * Wolf Pack 进化记忆系统测试脚本
 * 验证所有新功能是否正常工作
 */

const path = require('path');
const fs = require('fs');

// 测试配置
const tests = [
    {
        name: "目录结构检查",
        check: () => {
            const dirs = [
                ".claude/rules/issues/hotspots",
                ".claude/rules/patterns/experiences",
                ".claude/rules/issues",
                ".claude/rules/patterns",
                ".claude/rules/decisions",
                ".claude/rules/context",
                ".claude/rules/archived"
            ];

            const userDirs = [
                ".claude/rules",
                ".claude/rules/decisions",
                ".claude/rules/patterns",
                ".claude/rules/issues",
                ".claude/rules/context",
                ".claude/rules/archived"
            ];

            let projectOk = true;
            dirs.forEach(dir => {
                if (!fs.existsSync(dir)) {
                    console.log(`❌ 项目目录缺失: ${dir}`);
                    projectOk = false;
                }
            });

            let userOk = true;
            userDirs.forEach(dir => {
                const userDir = path.join(process.env.HOME || process.env.USERPROFILE, dir);
                if (!fs.existsSync(userDir)) {
                    console.log(`❌ 用户目录缺失: ${userDir}`);
                    userOk = false;
                }
            });

            return projectOk && userOk;
        }
    },
    {
        name: "配置文件检查",
        check: () => {
            const configPath = ".claude/rules/issues/config.yaml";
            if (!fs.existsSync(configPath)) {
                return false;
            }

            try {
                const content = fs.readFileSync(configPath, 'utf8');

                // 简单检查必需字段
                const required = ['hotspot:', 'experience:', 'warning:'];
                for (const field of required) {
                    if (!content.includes(field)) {
                        console.log(`❌ 配置文件缺少字段: ${field}`);
                        return false;
                    }
                }

                return true;
            } catch (e) {
                console.log(`❌ 配置文件格式错误: ${e.message}`);
                return false;
            }
        }
    },
    {
        name: "统计文件检查",
        check: () => {
            const statsPath = ".claude/rules/issues/stats.json";
            if (!fs.existsSync(statsPath)) {
                return false;
            }

            try {
                const stats = JSON.parse(fs.readFileSync(statsPath, 'utf8'));
                const required = ['totalIssues', 'openIssues', 'solvedIssues', 'categories'];

                for (const field of required) {
                    if (!(field in stats)) {
                        console.log(`❌ 统计文件缺少字段: ${field}`);
                        return false;
                    }
                }

                return true;
            } catch (e) {
                console.log(`❌ 统计文件格式错误: ${e.message}`);
                return false;
            }
        }
    },
    {
        name: "模板文件检查",
        check: () => {
            const templates = [
                "templates/memory/issue.md",
                "templates/memory/hotspot.md",
                "templates/memory/experience.md"
            ];

            let allOk = true;
            templates.forEach(template => {
                if (!fs.existsSync(template)) {
                    console.log(`❌ 模板文件缺失: ${template}`);
                    allOk = false;
                }
            });

            return allOk;
        }
    },
    {
        name: "Hook 脚本检查",
        check: () => {
            const hooks = [
                "hooks/session-start.js",
                "hooks/session-end.js"
            ];

            let allOk = true;
            hooks.forEach(hook => {
                if (!fs.existsSync(hook)) {
                    console.log(`❌ Hook 脚本缺失: ${hook}`);
                    allOk = false;
                    return;
                }

                const content = fs.readFileSync(hook, 'utf8');
                if (hook === 'session-start.js' && !content.includes('checkHotspotWarnings')) {
                    console.log(`❌ session-start.js 缺少热点检查功能`);
                    allOk = false;
                }

                if (hook === 'session-end.js' && !content.includes('promoteQualityMemory')) {
                    console.log(`❌ session-end.js 缺少记忆提升功能`);
                    allOk = false;
                }
            });

            return allOk;
        }
    },
    {
        name: "技能文档更新检查",
        check: () => {
            const skillPath = "skills/wolf-memory/SKILL.md";
            if (!fs.existsSync(skillPath)) {
                return false;
            }

            const content = fs.readFileSync(skillPath, 'utf8');
            if (!content.includes('错误追踪')) {
                console.log('❌ wolf-memory/SKILL.md 缺少错误追踪字段');
                return false;
            }

            return true;
        }
    }
];

// 运行测试
console.log('🧪 Wolf Pack 进化记忆系统测试');
console.log('='.repeat(50));

let passed = 0;
let failed = 0;

tests.forEach((test, index) => {
    console.log(`\n${index + 1}. ${test.name}`);

    try {
        if (test.check()) {
            console.log('✅ 通过');
            passed++;
        } else {
            console.log('❌ 失败');
            failed++;
        }
    } catch (e) {
        console.log(`❌ 错误: ${e.message}`);
        failed++;
    }
});

// 总结
console.log('\n' + '='.repeat(50));
console.log(`📊 测试结果: ${passed} 通过, ${failed} 失败`);

if (failed === 0) {
    console.log('\n🎉 所有测试通过！进化记忆系统已成功部署');
    console.log('\n📋 下一步建议:');
    console.log('1. 使用 /wolf-memory save issue 记录一些问题测试热点检测');
    console.log('2. 使用 /wolf-memory save pattern 记录一些模式测试经验提取');
    console.log('3. 关闭会话测试记忆提升功能');
} else {
    console.log('\n⚠️ 部分测试失败，请检查上述错误');
}

process.exit(failed);