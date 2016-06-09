[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True, Position=1)]
    [string]$server,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$database,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$user,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$pass
)

Add-Type -Path 'C:\Program Files\Microsoft SQL Server\120\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'
Add-Type -Path 'C:\Program Files (x86)\Microsoft SQL Server\130\DAC\bin\Microsoft.SqlServer.Dac.dll'

$username = [Environment]::UserName
$artifactPath = "C:\Users\$userName\Documents\" + $databaseName + ".bacpac"
$sw2 = [System.Diagnostics.Stopwatch]::StartNew()

# Export BACPAC
Write-Host "Exporting BACPAC from $server .."
$sw = [System.Diagnostics.Stopwatch]::StartNew()
$sw.Start()
$sourceDbConn = "Data Source=$server;Initial Catalog=$databaseName;Connection Timeout=0;User ID=$user;Password=$pass;"
$bacpacService = New-Object 'Microsoft.SqlServer.Dac.DacServices' $sourceDbConn
$bacpacService.ExportBacpac($artifactPath, $databaseName)
$sw.Stop()
Write-Host "Exported successfully"
Write-Host "Elapsed: " + $sw.Elapsed + "`n"

# Kill db if exists locally
$destServer = New-Object 'Microsoft.SqlServer.Management.Smo.Server' '(localdb)\MSSQLLocalDB'
if($destServer.Databases[$databaseName])
{
    $destServer.KillDatabase($databaseName)
    Write-Host "Killed existing database `n"
}

# Import BACPAC locally
$sw.Reset()
$sw.Start()
Write-Host "Importing BACPAC locally to (localdb)\MSSQLLocalDB .."
$destDbConn = "Data Source=(localdb)\MSSQLLocalDB; Connection Timeout=0;Integrated Security=true;"
$bacpacService2 = New-Object 'Microsoft.SqlServer.Dac.DacServices' $destDbConn
$bacpac = [Microsoft.SqlServer.Dac.BacPackage]::Load($artifactPath)
$bacpacService2.ImportBacpac($bacpac, $databaseName)
Write-Host "Successfully imported"
$sw.Stop()
Write-Host "Elapsed: "+ $sw.Elapsed + "`n"

Write-Host "Clearing artifact `n"

$sw2.Stop()
Write-Host "Process finished in: " $sw2.Elapsed
Remove-Item $artifactPath