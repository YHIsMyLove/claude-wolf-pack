#
# Wolf Pack SessionStart Hook (PowerShell)
# 功能: 读取项目规则并注入到系统上下文
#

param()

# 环境变量
$CLAUDE_PLUGIN_ROOT = if ($env:CLAUDE_PLUGIN_ROOT) { $env:CLAUDE_PLUGIN_ROOT } else { Split-Path -Parent (Split-Path -Parent $PSScriptRoot) }
$PROJECT_ROOT = if ($env:CLAUDE_PROJECT_ROOT) { $env:CLAUDE_PROJECT_ROOT } else { Get-Location }

# 规则目录 - 使用 .claude/rules/ 作为统一记忆系统
$RULES_DIR = Join-Path $PROJECT_ROOT ".claude/rules"
$MEMORY_DIR = Join-Path $PROJECT_ROOT ".claude/rules"
$WOLF_MD = Join-Path $PROJECT_ROOT ".wolf.md"
$MEMORY_INDEX = Join-Path $MEMORY_DIR "index.md"

# 输出标记 (用户可见)
Write-Host ""
Write-Host "🐺 Wolf Pack: 加载项目规则..." -ForegroundColor Cyan

# 函数: 安全读取文件
function Safe-Read {
    param([string]$File)

    if (Test-Path $File -PathType Leaf) {
        $content = Get-Content $File -Raw -Encoding UTF8
        if (-not [string]::IsNullOrWhiteSpace($content)) {
            Write-Host ""
            Write-Host "--- $File ---" -ForegroundColor DarkGray
            Write-Host $content
        }
    }
}

# 函数: 列出规则文件
function Get-RuleFiles {
    if (Test-Path $RULES_DIR -PathType Container) {
        Get-ChildItem -Path $RULES_DIR -Filter "*.md" -Recurse -File | Sort-Object FullName | Select-Object -ExpandProperty FullName
    }
}

# 函数: 初始化规则目录
function Initialize-RulesDir {
    if (-not (Test-Path $RULES_DIR -PathType Container)) {
        New-Item -ItemType Directory -Path $RULES_DIR -Force | Out-Null
    }

    # 创建子目录
    $subdirs = @("decisions", "patterns", "issues", "context", "archived")
    foreach ($subdir in $subdirs) {
        $path = Join-Path $RULES_DIR $subdir
        if (-not (Test-Path $path -PathType Container)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }

        # 创建 README
        $readme = Join-Path $path "README.md"
        if (-not (Test-Path $readme -PathType Leaf)) {
            "# $($subdir.Substring(0,1).ToUpper() + $subdir.Substring(1))`n`n此目录用于记录$($subdir)相关内容。`n" | Out-File -FilePath $readme -Encoding UTF8
        }
    }

    # 创建 index.md
    $indexPath = Join-Path $RULES_DIR "index.md"
    if (-not (Test-Path $indexPath -PathType Leaf)) {
        $indexContent = @"
# Wolf Pack 记忆索引

> 最后更新：$(Get-Date -Format "yyyy-MM-dd") | 总计：0 条记忆

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
"@
        $indexContent | Out-File -FilePath $indexPath -Encoding UTF8
    }
}

# 主逻辑
function Main {
    $rulesFound = $false

    # 初始化规则目录
    Initialize-RulesDir

    # 1. 读取 .wolf.md
    Safe-Read -File $WOLF_MD
    if (Test-Path $WOLF_MD -PathType Leaf) {
        $rulesFound = $true
    }

    # 2. 读取 rules/ 目录
    foreach ($ruleFile in (Get-RuleFiles)) {
        Safe-Read -File $ruleFile
        $rulesFound = $true
    }

    # 3. 加载记忆索引 (L2 记忆)
    Safe-Read -File $MEMORY_INDEX
    if (Test-Path $MEMORY_INDEX -PathType Leaf) {
        $rulesFound = $true
    }

    # 4. 输出状态
    if (-not $rulesFound) {
        Write-Host ""
        Write-Host "ℹ️  项目尚未初始化 Wolf Pack 记忆系统" -ForegroundColor Yellow
        Write-Host "   使用 /wolf-memory init 可初始化记忆结构" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "✓ 项目规则已加载" -ForegroundColor Green
    }

    Write-Host ""
}

# 执行
Main
