Import-Module "C:\Program Files\WindowsPowerShell\Modules\git\git.psm1"
function Initialize-Project {
    param (
        [string]$path = (Get-Location)
    )

    Check-GitPath $path

    $developmentBranch = Read-Host "Enter development branch name"

    if($developmentBranch -eq "" -or $null -eq $developmentBranch){
        Write-Error "development branch name cannot be null." -ErrorAction Stop
    }

    $gitPath = "$path\.git" 
    $workflowFile = "workflow"

    New-Item $gitPath -ItemType File -Name $workflowFile -Force

    @{ 
        developmentBranchName = $developmentBranch
    } | ConvertTo-Json | Out-File "$gitPath\$workflowFile" -Force
}

function Get-ProjectSetting {
    param (
        [string]$path = (Get-Location)
    )

    Check-GitPath -path $path

    $path = "$path\.git\workflow"

    if(!(Test-Path -Path $path)){
        Write-Error "File [$path] not exists. Call func [Initialize-Project]." -ErrorAction Stop
    }

    Get-Content -Path $path | ConvertFrom-Json
}

Export-ModuleMember Initialize-Project
Export-ModuleMember Get-ProjectSetting