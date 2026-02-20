<#
.SYNOPSIS
    为 Claude Code Agent Teams 创建 Windows Terminal 分屏

.DESCRIPTION
    使用 wt.exe CLI 创建多个分屏，每个分屏运行独立的 Claude Code agent
    支持动态数量的 agent 和混合分屏方向

.PARAMETER ProjectPath
    项目根路径（默认为当前目录）

.PARAMETER AgentCount
    Agent 数量（默认为 2）

.PARAMETER AgentNames
    Agent 名称数组（默认为 @("lead", "researcher")）

.PARAMETER TeamName
    团队名称（默认为 "wolf-pack"）

.EXAMPLE
    .\windows-terminal-split.ps1 -AgentCount 3 -AgentNames @("lead", "researcher", "coder")

.EXAMPLE
    .\windows-terminal-split.ps1 -ProjectPath "C:\my-project" -TeamName "dev-team"
#>

param(
    [string]$ProjectPath = (Get-Location).Path,
    [int]$AgentCount = 2,
    [string[]]$AgentNames = @("lead", "researcher"),
    [string]$TeamName = "wolf-pack"
)

# 错误处理函数
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# 检测 Windows Terminal
$wtPath = Get-Command wt -ErrorAction SilentlyContinue
if (-not $wtPath) {
    Write-ColorOutput "错误: Windows Terminal 未找到" "Red"
    Write-ColorOutput "请从 Microsoft Store 安装 Windows Terminal" "Yellow"
    Write-ColorOutput "https://aka.ms/terminal" "Cyan"
    exit 1
}

Write-ColorOutput "`n🐺 Wolf Pack Terminal 分屏启动器" "Cyan"
Write-ColorOutput "════════════════════════════════════════" "DarkGray"

# 设置环境变量
$env:CLAUDE_CODE_TEAM_NAME = $TeamName
$env:CLAUDE_CODE_PROJECT_PATH = $ProjectPath

Write-ColorOutput "项目路径: $ProjectPath" "Gray"
Write-ColorOutput "团队名称: $TeamName" "Gray"
Write-ColorOutput "Agent 数量: $AgentCount" "Gray"
Write-ColorOutput ""

# 构建 wt.exe 分屏命令
$wtCmd = "wt.exe"

# 主窗口（lead agent）
$leadName = if ($AgentNames.Count -gt 0) { $AgentNames[0] } else { "lead" }
$wtCmd += " --title `"${TeamName}-${leadName}`" --suppressApplicationTitle"
$wtCmd += " powershell.exe -NoExit"
$wtCmd += " -Command `"`$env:CLAUDE_CODE_AGENT_NAME='$leadName'; `$env:CLAUDE_CODE_AGENT_ID='$leadName-001'; `$env:CLAUDE_CODE_TEAM_NAME='$TeamName'; cd '$ProjectPath'; Write-Host '`'🐺 Agent: $leadName | Team: $TeamName`' -ForegroundColor Cyan; Write-Host '`'准备就绪。等待命令输入...`' -ForegroundColor Gray`""

# 附加分屏
for ($i = 1; $i -lt $AgentCount; $i++) {
    $agentName = if ($i -lt $AgentNames.Count) { $AgentNames[$i] } else { "agent-$i" }

    # 第一个 teammate 垂直分屏，其余水平分屏
    $splitDirection = if ($i -eq 1) { "-V" } else { "-H" }
    $splitSize = if ($i -eq 1) { "0.5" } else { "0.5" }

    $wtCmd += " ; split-pane $splitDirection"
    $wtCmd += " --size $splitSize"
    $wtCmd += " --title `"${TeamName}-${agentName}`" --suppressApplicationTitle"
    $wtCmd += " powershell.exe -NoExit"
    $wtCmd += " -Command `"`$env:CLAUDE_CODE_AGENT_NAME='$agentName'; `$env:CLAUDE_CODE_AGENT_ID='$agentName-00$i'; `$env:CLAUDE_CODE_TEAM_NAME='$TeamName'; cd '$ProjectPath'; Write-Host '`'🐺 Agent: $agentName | Team: $TeamName`' -ForegroundColor Cyan; Write-Host '`'准备就绪。等待命令输入...`' -ForegroundColor Gray`""
}

# 创建标志文件，表示分屏已启动
$flagFile = Join-Path $ProjectPath ".wolf/team-active.flag"
$flagContent = @{
    teamName = $TeamName
    agentCount = $AgentCount
    agentNames = $AgentNames
    startedAt = Get-Date -Format "o"
} | ConvertTo-Json
$flagContent | Out-File -FilePath $flagFile -Encoding UTF8

Write-ColorOutput "正在启动 Windows Terminal 分屏..." "Yellow"

# 执行分屏命令
try {
    Invoke-Expression $wtCmd
    Write-ColorOutput "`n✓ 分屏已启动" "Green"
    Write-ColorOutput "`n提示: 每个 Agent 窗口需要手动输入命令来启动相应任务" "Yellow"
    Write-ColorOutput "      环境变量已设置用于标识当前 Agent 身份" "Gray"
}
catch {
    Write-ColorOutput "`n错误: 启动分屏失败" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    exit 1
}

Write-ColorOutput "`n════════════════════════════════════════`n" "DarkGray"
