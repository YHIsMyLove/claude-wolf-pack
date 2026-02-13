#!/bin/bash
#
# Wolf Pack SessionEnd Hook
# 功能: 分析会话并追加洞察到规则文件，记录文件变化
#

set -e

# 环境变量
CLAUDE_PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_ROOT="${CLAUDE_PROJECT_ROOT:-$(pwd)}"

# 规则目录
RULES_DIR="$PROJECT_ROOT/rules"
TRACE_DIR="$PROJECT_ROOT/.wolf/trace"
SESSION_HISTORY="${CLAUDE_SESSION_HISTORY:-}"

# 输出日志
LOG_FILE="$RULES_DIR/.session-log.txt"

# 函数: 初始化规则目录
init_rules_dir() {
    mkdir -p "$RULES_DIR"

    # 创建必要的文件
    [[ -f "$RULES_DIR/context.md" ]] || touch "$RULES_DIR/context.md"
    [[ -f "$RULES_DIR/decisions.md" ]] || touch "$RULES_DIR/decisions.md"
    [[ -f "$RULES_DIR/patterns.md" ]] || touch "$RULES_DIR/patterns.md"
    [[ -f "$RULES_DIR/issues.md" ]] || touch "$RULES_DIR/issues.md"
}

# 函数: 初始化跟踪目录
init_trace_dir() {
    mkdir -p "$TRACE_DIR"
}

# 函数: 追加到规则文件 (带时间戳)
append_to_rule() {
    local category="$1"  # issues | patterns | decisions | context
    local content="$2"
    local file="$RULES_DIR/$category.md"

    # 确保文件存在
    [[ -f "$file" ]] || touch "$file"

    # 追加内容
    {
        echo ""
        echo "## [$(date +%Y-%m-%d)] - 会话结束"
        echo ""
        echo "$content"
        echo ""
    } >> "$file"
}

# 函数: 记录会话日志
log_session() {
    mkdir -p "$RULES_DIR"

    {
        echo "=================================="
        echo "Session End: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Project: $PROJECT_ROOT"
        echo "=================================="
        echo ""
    } >> "$LOG_FILE"
}

# 函数: 记录文件变化
log_file_changes() {
    init_trace_dir

    local trace_file="$TRACE_DIR/$(date +%Y-%m-%d)-files.md"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # 检查是否在 git 仓库中
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # 获取修改的文件
        local modified=$(git diff --name-only 2>/dev/null | wc -l)
        local added=$(git diff --name-only --cached 2>/dev/null | wc -l)
        local untracked=$(git ls-files --others --exclude-standard | wc -l)

        # 记录变化
        {
            echo "## 文件变化 - $timestamp"
            echo ""
            echo "### 修改的文件"
            if [[ $modified -gt 0 ]]; then
                git diff --name-only 2>/dev/null | while read file; do
                    echo "- \`$file\`"
                done
            else
                echo "无"
            fi

            echo ""
            echo "### 新增的文件 (暂存区)"
            if [[ $added -gt 0 ]]; then
                git diff --name-only --cached 2>/dev/null | while read file; do
                    echo "- \`$file\`"
                done
            else
                echo "无"
            fi

            echo ""
            echo "### 未跟踪的文件"
            if [[ $untracked -gt 0 ]]; then
                git ls-files --others --exclude-standard | head -20 | while read file; do
                    echo "- \`$file\`"
                done
                if [[ $untracked -gt 20 ]]; then
                    echo "... (还有 $((untracked - 20)) 个文件)"
                fi
            else
                echo "无"
            fi

            echo ""
            echo "### 统计"
            echo "修改: $modified | 新增: $added | 未跟踪: $untracked"
            echo ""
            echo "---"
            echo ""
        } >> "$trace_file"
    else
        # 非 git 项目，记录基本信息
        {
            echo "## 文件变化 - $timestamp"
            echo ""
            echo "非 Git 项目，无法追踪文件变化"
            echo ""
            echo "---"
            echo ""
        } >> "$trace_file"
    fi
}

# 函数: 记录会话统计
log_session_stats() {
    local stats_file="$TRACE_DIR/$(date +%Y-%m-%d)-stats.md"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    {
        echo "## 会话统计 - $timestamp"
        echo ""
        echo "- 项目: \`$PROJECT_ROOT\`"
        echo "- 时间: $timestamp"
        echo ""
        echo "---"
        echo ""
    } >> "$stats_file"
}

# 主逻辑
main() {
    # 初始化目录
    init_rules_dir
    init_trace_dir

    # 记录会话日志
    log_session

    # 记录文件变化
    log_file_changes

    # 记录会话统计
    log_session_stats

    # 如果有会话历史路径，可以进一步分析
    # 这里简化处理，实际分析由 /wolf-insights 命令完成

    echo "🐺 Wolf Pack: 会话已记录" >&2
    echo "   - 文件变化: $TRACE_DIR/$(date +%Y-%m-%d)-files.md" >&2
}

# 执行
main "$@"
