## PSReadLine
## ================================================================================ 

Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

Set-PSReadLineKeyHandler -Chord "Ctrl+r" -ViMode Insert -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Chord "Ctrl+s" -ViMode Insert -Function ForwardSearchHistory

## As a matter of habit, remap $ and _ keys from French AZERTY layout
## to the new keys from the French AZERTY-NF layout

Set-PSReadLineKeyHandler -Key '+' -ViMode Command -Function MoveToEndOfLine
Set-PSReadLineKeyHandler -Key "’" -ViMode Command -Function GotoFirstNonBlankOfLine

## Azure PowerShell
## ================================================================================ 

Enable-AzureRmAlias -Scope CurrentUser
Set-Alias -Name Start-Deploy -Value /workspace/deploy.ps1 -Scope Global
