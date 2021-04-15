$script:imports = @{}

function Import-ProProfile {
    [CmdletBinding()]
    param (
        # Do not support importing files, otherwise you need to do scoping kung-fu to import into user scope.
        # Instead use dot-sourcing in a scriptblock. This also allows users to provide parameters to their script files directly.
        # [ValidateScript({ Test-Path -Path $PSItem })]
        # [string[]]$Path,
        [scriptblock[]]$ScriptBlock,
        [int]$Delay = 500
    )
    process {
        $timer = New-Object Timers.Timer
        $timer.Interval = $Delay
        $timer.Enabled = $true
        # run once
        $timer.AutoReset = $false
        
        $id = (New-Guid).Guid.ToString()
        $moduleName = $ExecutionContext.SessionState.Module.Name

        $script:imports.Add($id, $ScriptBlock)
        $params = @{
            InputObject         = $timer
            EventName           = "Elapsed"
            SourceIdentifier    = $id
            SupportEvent        = $true
            Action              = [scriptblock]::Create("& (Get-Module $moduleName) { Invoke-Import -Id $id }" )
        }

        $null = Register-ObjectEvent @params 
    }
}

function Invoke-Import ($Id) { 
    $state = $script:imports[$id]

    try {
        # clean up the callback
        Unregister-Event -SourceIdentifier $id
        foreach ($i in $state) { 
            # We are running in module scope, but the scriptblock is bound to what
            # ever scope created it. Dot-source into that scope so user can use the variables 
            # and functions from it in subsequent calls.
            # 
            # You might also want to add try catch here to be able to progress to next scriptblock if one fails
            . $i
        }
    }
    finally { 
        # clean up callbacks because we invoked them
        $script:imports.Remove($id)
    }
}

Export-ModuleMember -Function Import-ProProfile