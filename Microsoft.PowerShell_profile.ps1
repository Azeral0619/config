oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\powerlevel10k_lean.omp.json" | Invoke-Expression
Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine
Import-Module -Name posh-git
Import-Module "$($(Get-Item $(Get-Command scoop.ps1).Path).Directory.Parent.FullName)\modules\scoop-completion"
