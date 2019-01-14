enum Branches {
    feature
    bugfix
}

function Check-GitPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    if(!(Test-Path -Path "$path/.git")){
        Write-Error $"Invalid path ($path). This is path no git repository." -ErrorAction Stop
    }
}

function Get-GitRepositoryInfo {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path
    )
    
    Check-GitPath $path

    [string]$urlRow = Get-Content "$path/.git/config" | Select-String "url"

    $url = $urlRow.SubString($urlRow.LastIndexOf(' ')).Trim()
    
    $urlElements = $url.Split('/')

    $branches = @{}

    git -C $path branch | ForEach-Object{
            
        $branch = $_.Trim()

        if($branch[0] -eq '*'){
            $branches.Add($branch.Substring(2, $branch.Length - 2), $true)
        }
        else{
            $branches.Add($branch, $false)
        }
    }

    @{
        path = $path
        host = $urlElements[2]
        owner = $urlElements[3]
        name = $urlElements[4].Substring(0, $urlElements[4].IndexOf('.'))
        branches = $branches
    }
}

function New-Branch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$baseBranch,
        [Parameter(Mandatory=$true)]
        [Branches]$type,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    Check-GitPath $path
    
    git -C $path checkout $baseBranch
    git -C $path pull
    git -C $path checkout -b "$type/$name"
}

function New-Feature {
    param (
        [Parameter(Mandatory=$true)]
        [string]$name,
        [string]$path = (Get-Location)
    )

    New-Branch -baseBranch (Get-ProjectSetting).developmentBranchName -type ([Branches]::feature) -name $name -Path $path
}

function Push-Branch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$path,
        [Parameter(Mandatory=$true)]
        [string]$comment
    )
    
    Check-GitPath $path

    $currentBranch = git symbolic-ref --short HEAD

    [string]$status = git -C $path status

    if($status -notlike '*use "git add*'){
        Write-Error "Local branch [$currentBranch] not modified." -ErrorAction Stop
    }
        
    git -C $path checkout (Get-ProjectSetting).developmentBranchName
    git -C $path pull

    git -C $path checkout $currentBranch
    $status = git -C $path merge (Get-ProjectSetting).developmentBranchName

    if($status -like '*CONFLICT*'){
        Write-Error $status -ErrorAction Stop
    }

    git -C $path add *
    git -C $path commit -m $comment
    git -C $path push -u origin $currentBranch
}

Export-ModuleMember New-Feature
Export-ModuleMember Push-Branch
Export-ModuleMember Get-GitRepositoryInfo
Export-ModuleMember Check-GitPath