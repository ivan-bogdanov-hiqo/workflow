enum Branches {
    feature
    bugfix
}
function New-Branch {
    param (
        [Parameter(Mandatory=$true)]
        [string]$baseBranch,
        [Parameter(Mandatory=$true)]
        [Branches]$type,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [string]$path
    )

    if($path -eq ""){
        $path = $PSCommandPath.Substring(0, $PSCommandPath.LastIndexOf('\'))
    }

        if(!(Test-Path -Path "$path/.git")){
            Write-Error $"Invalid path ($path). This is path no git repository." -ErrorAction Stop
        }
    
        git checkout $baseBranch
        git pull
        git checkout -b "$type/$name"
}

function New-Feature {
    param (
        [Parameter(Mandatory=$true)]
        [string]$name,
        [string]$path
    )

    New-Branch -baseBranch 'development' -type ([Branches]::feature) -name $name -Path $path
}

Export-ModuleMember New-Feature