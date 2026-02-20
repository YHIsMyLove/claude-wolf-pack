<#
.SYNOPSIS
    Agent 启动包装器 - 为独立 Agent 窗口提供启动脚本

.DESCRIPTION
    此脚本由 Claude Code 在分屏环境中调用，用于启动特定 Agent
    读取环境变量确定 Agent 身份，然后执行相应的任务

.PARAMETER TaskDescription
    任务描述（可选）

.EXAMPLE
    .\agent-launcher.ps1 -TaskDescription "分析代码结构"

.NOTES
    环境变量（由主进程设置）:
    - CLAUDE_CODE_TEAM_NAME: 团队名称
    - CLAUDE_CODE_AGENT_NAME: 当前 Agent 名称
    - CLAUDE_CODE_AGENT_ID: 当前 Agent ID
    - CLAUDE_CODE_PROJECT_PATH: 项目路径
#>

param(
    [string]$TaskDescription = ""
)

# 从环境变量获取配置
$TeamName = $env:CLAUDE_CODE_TEAM_NAME
$AgentName = $env:CLAUDE_CODE_AGENT_NAME
$AgentId = $env:CLAUDE_CODE_AGENT_ID
$ProjectPath = $env:CLAUDE_CODE_PROJECT_PATH

function Write-AgentHeader {
    param([string]$Name, [string]$Team)

    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  🐺 Wolf Pack Agent                    ║" -ForegroundColor Cyan
    Write-Host "╠════════════════════════════════════════╣" -ForegroundColor DarkGray
    Write-Host ("║  Agent: {0,-30} ║" -f $Name) -ForegroundColor White
    Write-Host ("║  Team:  {0,-30} ║" -f $Team) -ForegroundColor White
    Write-Host ("║  ID:    {0,-30} ║" -f $AgentId) -ForegroundColor Gray
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-AgentPrompt {
    Write-Host ">>> " -NoNewline -ForegroundColor Green
}

# 主逻辑
if (-not $AgentName) {
    Write-Host "错误: 未找到 Agent 名称环境变量" -ForegroundColor Red
    Write-Host "此脚本应在由 windows-terminal-split.ps1 创建的分屏中运行" -ForegroundColor Yellow
    exit 1
}

Write-AgentHeader -Name $AgentName -Team $TeamName

Write-Host "准备就绪。" -ForegroundColor Gray
Write-Host "等待主进程分配任务..." -ForegroundColor DarkGray
Write-Host ""

# 任务提示
if ($TaskDescription) {
    Write-Host "任务: $TaskDescription" -ForegroundColor Yellow
    Write-Host ""
}

# 显示提示符
Write-AgentPrompt
