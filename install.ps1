$moduleRootPath = 'C:\Program Files\WindowsPowerShell\Modules'

Get-ChildItem . | ForEach-Object{
    
    if($_.Extension -eq '.psm1'){
        
        $moduleName = $_.Name.Substring(0, $_.Name.LastIndexOf('.'))
        
        New-Item -ItemType Directory -Path "$moduleRootPath/$moduleName" -Force

        Copy-Item -Path $_.FullName -Destination "$moduleRootPath/$moduleName/$_" -Force
    }
}