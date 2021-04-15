# proprofile
~Faster~ Postpone importing PowerShell Profiles

Usage:

```powershell
# Import this module 
Import-Module -Name proprofile

# Schedule work to be run after the delay
Import-ProProfile -ScriptBlock { 
    # Your code to be postponed.
    
    # Run any code:
    Write-Host "See you later!"

    # Import modules:
    Import-Module -Name PSReadline

    # Set variables: 
    $hello = "abc"

    # Import script files by dot sourcing them, you can provide parameters as well:
    . somefile.ps1 -Name "some name"
} -Delay 1000
```

