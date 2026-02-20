#
# Wolf Pack SessionEnd Hook (PowerShell)
# 功能: 分析会话并追加洞察到规则文件，记录文件变化
#

param()

# 环境变量
$CLAUDE_PLUGIN_ROOT = if ($env:CLAUDE_PLUGIN_ROOT) { $env:CLAUDE_PLUGIN_ROOT } else { Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$PROJECT_ROOT = if ($env:CLAUDE_PROJECT_ROOT) { $env:CLAUDE_PROJECT_ROOT } else { Get-Location }
$SESSION_HISTORY = if ($env:CLAUDE_SESSION_HISTORY) { $env:CLAUDE_SESSION_HISTORY } else { "" }

# 规则目录
$RULES_DIR = Join-Path $PROJECT_ROOT ".claude/rules"
$TRACE_DIR = Join-Path $PROJECT_ROOT ".wolf/trace"

# 输出日志
$LOG_FILE = Join-Path $RULES_DIR ".session-log.txt"

# 函数: 初始化目录
function Initialize-Directories {
    if (-not (Test-Path $RULES_DIR -PathType Container)) {
        New-Item -ItemType Directory -Path $RULES_DIR -Force | Out-Null
    }
    if (-not (Test-Path $TRACE_DIR -PathType Container)) {
        New-Item -ItemType Directory -Path $TRACE_DIR -Force | Out-Null
    }
}

# 函数: 追加到规则文件 (带时间戳)
function Append-ToRule {
    param(
        [string]$Category,  # issues | patterns | decisions | context
        [string]$Content
    )

    $file = Join-Path $RULES_DIR "$Category.md"

    # 确保文件存在
    if (-not (Test-Path $file -PathType Leaf)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }

    # 追加内容
    $timestamp = Get-Date -Format "yyyy-MM-dd"
    $contentToAppend = @"

## [$timestamp] - 会话结束

$Content

"@
    Add-Content -Path $file -Value $contentToAppend -Encoding UTF8
}

# 函数: 记录会话日志
function Write-SessionLog {
    Initialize-Directories

    $logEntry = @"
==================================
Session End: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Project: $PROJECT_ROOT
==================================

"@
    Add-Content -Path $LOG_FILE -Value $logEntry -Encoding UTF8
}

# 函数: 记录文件变化
function Write-FileChanges {
    Initialize-Directories

    $today = Get-Date -Format "yyyy-MM-dd"
    $traceFile = Join-Path $TRACE_DIR "$today-files.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # 检查是否在 git 仓库中
    $gitRoot = Get-GitRoot

    $content = @"

## 文件变化 - $timestamp

"@

    if ($gitRoot) {
        # Git 项目
        $modified = @(git diff --name-only 2>$null) | Where-Object { $_ -ne "" }
        $added = @(git diff --name-only --cached 2>$null) | Where-Object { $_ -ne "" }
        $untracked = @(git ls-files --others --exclude-standard 2>$null) | Where-Object { $_ -ne "" }

        $content += @"

### 修改的文件
$($modified | ForEach-Object { "- \`"$_\`"" } | Out-String).Trim()
$(-not $modified ? "无" : "")

### 新增的文件 (暂存区)
$($added | ForEach-Object { "- \`"$_\`"" } | Out-String).Trim()
$(-not $added ? "无" : "")

### 未跟踪的文件
$($untracked | Select-Object -First 20 | ForEach-Object { "- \`"$_\`"" } | Out-String).Trim()
$(-not $untracked ? "无" : "")

### 统计
修改: $($modified.Count) | 新增: $($added.Count) | 未跟踪: $($untracked.Count)

"@
    } else {
        # 非 git 项目
        $content += @"
非 Git 项目，无法追踪文件变化

"@
    }

    $content += @"

---

"@
    Add-Content -Path $traceFile -Value $content -Encoding UTF8
}

# 函数: 记录会话统计
function Write-SessionStats {
    $today = Get-Date -Format "yyyy-MM-dd"
    $statsFile = Join-Path $TRACE_DIR "$today-stats.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $content = @"

## 会话统计 - $timestamp

- 项目: \`"$PROJECT_ROOT\`"
- 时间: $timestamp

---

"@
    Add-Content -Path $statsFile -Value $content -Encoding UTF8
}

# 函数: 记录会话洞察
function Write-SessionInsights {
    $insightsFile = Join-Path $RULES_DIR ".session-insights.md"
    $timestamp = Get-Date -Format "yyyy-MM-dd"
    $timeHuman = Get-Date -Format "HH:mm:ss"

    # 确保文件存在
    Initialize-Directories
    if (-not (Test-Path $insightsFile -PathType Leaf)) {
        New-Item -ItemType File -Path $insightsFile -Force | Out-Null
    }

    $historyText = if ($SESSION_HISTORY) { $SESSION_HISTORY } else { "N/A" }

    $content = @"

## [$timestamp] - 会话摘要

**时间**: $timeHuman
**会话历史**: $historyText

---

"@
    Add-Content -Path $insightsFile -Value $content -Encoding UTF8
}

# 函数: 获取 Git 根目录
function Get-GitRoot {
    try {
        $result = git rev-parse --git-dir 2>$null
        if ($result) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# 主逻辑
function Main {
    # 记录会话日志
    Write-SessionLog

    # 记录文件变化
    Write-FileChanges

    # 记录会话统计
    Write-SessionStats

    # 记录会话洞察
    Write-SessionInsights

    # 输出通知
    $today = Get-Date -Format "yyyy-MM-dd"
    Write-Host ""
    Write-Host "🐺 Wolf Pack: 会话已记录" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📂 摘要: .claude/rules/.session-insights.md" -ForegroundColor Gray
    Write-Host "📁 文件变化: .wolf/trace/$today-files.md" -ForegroundColor Gray
    Write-Host "📊 会话统计: .wolf/trace/$today-stats.md" -ForegroundColor Gray
    Write-Host ""
    Write-Host "提示: 使用 /wolf-memory 查看和管理记忆" -ForegroundColor DarkGray
    Write-Host ""
}

# 执行
Main
