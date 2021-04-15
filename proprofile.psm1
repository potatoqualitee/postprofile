
function Import-ProProfile {
    [CmdletBinding()]
    param (
        [ValidateScript({ Test-Path -Path $PSItem })]
        [string[]]$Path,
        [scriptblock[]]$ScriptBlock,
        [int]$Delay = 500
    )
    begin {
        $allscripts = New-Object System.Collections.ArrayList
    }
    process {
        foreach ($file in $Path) {
            $null = $allscripts.Add([io.file]::ReadAllText((Resolve-Path -Path $file)))
        }
        foreach ($block in $ScriptBlock) {
            $null = $allscripts.Add($block)
        }

        $null = $allscripts.Add('$timer.Stop(); $timer.Dispose()')

        $timer = New-Object Timers.Timer
        $timer.Interval = $Delay
        $timer.Enabled = $true
        
        $params = @{
            InputObject         = $timer
            EventName           = "Elapsed"
            SourceIdentifier    = "proprofile"
            SupportEvent        = $true
            Action              = [scriptblock]::Create(($allscripts -join "`n"))
        }
        $null = Register-ObjectEvent @params
    }
}