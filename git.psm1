$developmentBranch = 'development'

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
    
    git $path checkout $baseBranch
    git $path pull
    git $path checkout -b "$type/$name"
}

function New-Feature {
    param (
        [Parameter(Mandatory=$true)]
        [string]$name,
        [string]$path = (Get-Location)
    )

    New-Branch -baseBranch $developmentBranch -type ([Branches]::feature) -name $name -Path $path
}

function Push-Branch {
    param (
        [string]$path = (Get-Location)
    )
    
    Check-GitPath $path

    git status -b --short

    Write-Host -ForegroundColor Green "Press key [Enter] to continue..."

    if([System.Console]::ReadKey().Key -eq [System.ConsoleKey]::Enter){
        
        $comment = Read-Host "Enter comment"
        
        if($comment -eq "" -or $null -eq $comment){
            Write-Error "Comment cannot be null." -ErrorAction Stop
        }

        $currentBranch = git symbolic-ref --short HEAD

        [string]$status = git -C $path status

        if($status -notlike '*use "git add*'){
            Write-Error "Local branch [$currentBranch] not modified." -ErrorAction Stop
        }
        
        git -C $path checkout $developmentBranch
        git -C $path pull

        git -C $path checkout $currentBranch
        $status = git -C $path merge $developmentBranch

        if($status -like '*CONFLICT*'){
            Write-Error $status -ErrorAction Stop
        }

        git -C $path add *
        git -C $path commit -m $comment
        git -C $path push -u origin $currentBranch
    }
}

Export-ModuleMember New-Feature
Export-ModuleMember Push-Branch