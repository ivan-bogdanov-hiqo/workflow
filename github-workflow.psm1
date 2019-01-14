Import-Module "C:\Program Files\WindowsPowerShell\Modules\github\github.psm1"
Import-Module "C:\Program Files\WindowsPowerShell\Modules\git\git.psm1"
Import-Module "C:\Program Files\WindowsPowerShell\Modules\settings-project\settings-project.psm1"

function Complete-Task {

    $path = (Get-Location)

    git -C $path status -b --short

    Write-Host -ForegroundColor Green "Press key [Enter] to continue..."

    if([System.Console]::ReadKey().Key -eq [System.ConsoleKey]::Enter){
        
        $comment = Read-Host "Enter comment"

        if($comment -eq "" -or $null -eq $comment){
            Write-Error "Comment cannot be null." -ErrorAction Stop
        }

        $head = (Get-GitRepositoryInfo (Get-Location)).branches.GetEnumerator() | Where-Object {
            $_.value -eq $true
        } | Select-Object -ExpandProperty Name
        
        [hashtable]$repositoryInfo = Get-GitRepositoryInfo $path

        [string]$host = $repositoryInfo.host
        [string]$owner = $repositoryInfo.owner
        [string]$repository = $repositoryInfo.name
    
        $uri = "https://api.$host/repos/$owner/$repository/pulls"

        try {
            Push-Branch -path $path -comment $comment

            Request-PullGitHub -uri $uri -head $head -base (Get-ProjectSetting).developmentBranchName -comment $comment
        }
        catch {
            $Error[0]
        }
    }
}

Export-ModuleMember Complete-Task