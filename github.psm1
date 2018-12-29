[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$token = ""
$tokenHeader = @{ "Authorization"= "token $token" }

function Pull-GitHub {
    param (
        [Parameter(Mandatory=$true)]
        [string]$uri,
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

    Invoke-WebRequest -Uri $uri -ContentType 'application/json' -Method Post -Headers $tokenHeader -Body $body
}

Export-ModuleMember Pull-GitHub