Import-Module "C:\Program Files\WindowsPowerShell\Modules\git\git.psm1"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$token = ""
$tokenHeader = @{ "Authorization"= "token $token" }

$developmentBranch = 'development'

function Pull-GitHub {
    param (
        [string]$path = (Get-Location),
        [Parameter(Mandatory=$true)]
        [string]$head,
        [Parameter(Mandatory=$true)]
        [string]$base,
        [Parameter(Mandatory=$true)]
        [string]$comment
    )

    $body = @{
        title = $comment
        head = $head
        base = $base
    } | ConvertTo-JSON

    [hashtable]$repositoryInfo = Get-GitRepositoryInfo $path

    [string]$host = $repositoryInfo.host
    [string]$owner = $repositoryInfo.owner
    [string]$repository = $repositoryInfo.name

    $uri = "https://api.$host/repos/$owner/$repository/pulls"

    Invoke-WebRequest -Uri $uri -ContentType 'application/json' -Method Post -Headers $tokenHeader -Body $body
}

function Pull-GitHubDevelopment {
    param (
        [Parameter(Mandatory=$true)]
        [string]$head,
        [Parameter(Mandatory=$true)]
        [string]$comment
    )
    
    Pull-GitHub -head $head -base $developmentBranch -comment $comment
}

Export-ModuleMember Pull-GitHubDevelopment