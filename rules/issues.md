# 问题记录

## [2026-02-13] - WSL 和 Git Bash 环境问题

**类别**: 环境配置

**上下文**
启动 Claude Code 时出现 WSL 和 Git Bash 相关错误：
- WSL localhost 名称无法解析 (FO*g\��P0R)
- Git Bash.exe 路径不存在 (C:\Program Files\Git\bin\bash.exe)

**尝试方案**
1. 检查 WSL 配置
2. 验证 Git 安装路径

**最终方案**
使用 Unix 风格路径 (`/c/Users/...`) 并在 Git Bash 环境中执行命令

**相关文件**
- `hooks/session-start.sh`
- `hooks/session-end.sh`

**标签**: `wsl`, `git-bash`, `environment`, `hook`
**状态**: 已解决
