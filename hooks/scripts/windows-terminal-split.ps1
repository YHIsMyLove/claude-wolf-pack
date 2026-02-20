<#
.SYNOPSIS
    为 Claude Code Agent Teams 创建 Windows Terminal 分屏

.DESCRIPTION
    使用 wt.exe CLI 创建分屏窗口，每个分屏运行独立的 Claude Code agent

.PARAMETER ProjectPath
    项目根路径（默认为当前目录）

.PARAMETER AgentCount
    Agent 数量（默认为 2）

.PARAMETER AgentNames
    Agent 名称数组（默认为 @("lead", "researcher")）

.PARAMETER TeamName
    团队名称（默认为 "wolf-pack"）

.EXAMPLE
    .\windows-terminal-split.ps1 -AgentCount 2
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
$wtExePath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\wt.exe"
if (-not (Test-Path $wtExePath)) {
    $wtExePath = "wt.exe"
    $wtPath = Get-Command wt -ErrorAction SilentlyContinue
    if (-not $wtPath) {
        Write-ColorOutput "错误: Windows Terminal 未找到" "Red"
        Write-ColorOutput "请从 Microsoft Store 安装 Windows Terminal" "Yellow"
        exit 1
    }
}

Write-ColorOutput "`n[Wolf Pack] Terminal Splitter" "Cyan"
Write-ColorOutput "========================" "Gray"

Write-ColorOutput "Project: $ProjectPath" "Gray"
Write-ColorOutput "Team: $TeamName" "Gray"
Write-ColorOutput "Agents: $AgentCount" "Gray"
Write-ColorOutput ""

# 创建标志文件
$flagFile = Join-Path $ProjectPath ".wolf/team-active.flag"
$flagDir = Split-Path $flagFile -Parent
if (-not (Test-Path $flagDir)) {
    New-Item -ItemType Directory -Path $flagDir -Force | Out-Null
}

$flagContent = @{
    teamName = $TeamName
    agentCount = $AgentCount
    agentNames = $AgentNames
    startedAt = Get-Date -Format "o"
} | ConvertTo-Json -Depth 10
$flagContent | Out-File -FilePath $flagFile -Encoding UTF8

Write-ColorOutput "Starting split panes..." "Yellow"

# 构建 wt.exe 命令（使用 split-pane 而非 new-tab）
$wtCmd = "wt.exe"

# 第一个 agent（主窗口）
$agent1Name = if ($AgentNames.Count -gt 0) { $AgentNames[0] } else { "lead" }
$agent1Id = "$agent1Name-001"
$cmd1 = "`$env:CLAUDE_CODE_AGENT_NAME='$agent1Name'; `$env:CLAUDE_CODE_AGENT_ID='$agent1Id'; `$env:CLAUDE_CODE_TEAM_NAME='$TeamName'; Set-Location '$ProjectPath'; Clear-Host; Write-Host '[Agent: $agent1Name]' -ForegroundColor Cyan"

$wtCmd += " -d `"$ProjectPath`" powershell.exe -NoExit -Command `"$cmd1`""

# 添加分屏（垂直分割）
for ($i = 1; $i -lt $AgentCount; $i++) {
    $agentName = if ($i -lt $AgentNames.Count) { $AgentNames[$i] } else { "agent-$i" }
    $agentId = "$agentName-00$i"
    $cmd = "`$env:CLAUDE_CODE_AGENT_NAME='$agentName'; `$env:CLAUDE_CODE_AGENT_ID='$agentId'; `$env:CLAUDE_CODE_TEAM_NAME='$TeamName'; Set-Location '$ProjectPath'; Clear-Host; Write-Host '[Agent: $agentName]' -ForegroundColor Cyan"

    # 使用 ; split-pane
    $wtCmd += " `; split-pane -V"
    $wtCmd += " -d `"$ProjectPath`" powershell.exe -NoExit -Command `"$cmd`""
}

# 执行 - 使用 cmd /c 启动以避免 PowerShell 解析问题
try {
    $batFile = Join-Path $env:TEMP "wolf-terminal-$([Guid]::NewGuid()).cmd"
    $wtCmd | Out-File -FilePath $batFile -Encoding ASCII

    Start-Process "cmd.exe" -ArgumentList "/c `"$batFile`"" -NoNewWindow

    Write-ColorOutput "[OK] Split panes started" "Green"
    Write-ColorOutput "" "Gray"
    Write-ColorOutput "Tip: Use Alt+Shift+Plus to split vertically" "Gray"
    Write-ColorOutput "     Use Alt+Shift+- to split horizontally" "Gray"
}
catch {
    Write-ColorOutput "[ERROR] Failed to start" "Red"
    Write-ColorOutput $_.Exception.Message "Red"
    exit 1
}

Write-ColorOutput "========================`n" "Gray"
