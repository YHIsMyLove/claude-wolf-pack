#!/bin/bash
#
# Wolf Pack SessionStart Hook
# 功能: 读取项目规则并注入到系统上下文
#

set -e

# 环境变量 (由 Claude Code 注入)
CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_ROOT="${CLAUDE_PROJECT_ROOT:-$(pwd)}"

# 规则目录
RULES_DIR="$PROJECT_ROOT/rules"
WOLF_MD="$PROJECT_ROOT/.wolf.md"

# 输出标记 (用户可见)
echo ""
echo "🐺 Wolf Pack: 加载项目规则..."

# 函数: 安全读取文件
safe_read() {
    local file="$1"
    if [[ -f "$file" && -r "$file" && -s "$file" ]]; then
        echo ""
        echo "--- $file ---"
        cat "$file"
    fi
}

# 函数: 列出规则文件
list_rules() {
    if [[ -d "$RULES_DIR" ]]; then
        find "$RULES_DIR" -name "*.md" -type f | sort
    fi
}

# 主逻辑
main() {
    local rules_found=false

    # 1. 读取 .wolf.md
    if [[ -f "$WOLF_MD" ]]; then
        safe_read "$WOLF_MD"
        rules_found=true
    fi

    # 2. 读取 rules/ 目录
    if [[ -d "$RULES_DIR" ]]; then
        for rule_file in $(list_rules); do
            safe_read "$rule_file"
            rules_found=true
        done
    fi

    # 3. 如果没有规则，提供初始化提示
    if [[ "$rules_found" == "false" ]]; then
        echo ""
        echo "ℹ️  项目尚未初始化 Wolf Pack 规则"
        echo "   使用 /wolf-remember init 可初始化规则结构"
    else
        echo ""
        echo "✓ 项目规则已加载"
    fi

    echo ""
}

# 执行
main "$@"
