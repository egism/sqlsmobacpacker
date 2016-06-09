# sqlsmobacpacker
Automatically migrates mssql .bacpac between servers (Destination: (localdb)\MSSQLLocalDB).

Usage in powershell:
```.\sqlimporter.ps1 -server 0.0.0.0 -database DatabaseName -user username -pass password```

Dependencies:
Microsoft.SqlServer.Smo.dll
Microsoft.SqlServer.Dac.dll
