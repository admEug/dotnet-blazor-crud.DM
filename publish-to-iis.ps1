# publish-to-iis.ps1

# 1. Define paths and variables
$projectPath = "D:\Repos\dotnet-blazor-crud.DM\Blazorcrud.Server\Blazorcrud.Server.csproj"
$publishFolder = "C:\inetpub\wwwroot\BlazorCrudApp"

Write-Host "🚀 Publishing Blazor Server App..."
dotnet publish $projectPath -c Release -o $publishFolder

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Publish failed. Check the project path or build errors."
    Read-Host "Press Enter to exit..."
    exit 1
}

Write-Host "✅ App published to: $publishFolder"

# -----------------------
# 3. Set Permissions for IIS
# -----------------------

Write-Host "🔧 Setting folder permissions for IIS_IUSRS..."
$acl = Get-Acl $publishFolder
$permission = "IIS_IUSRS","Modify","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl $publishFolder $acl
Write-Host "✅ Permissions set successfully."

Write-Host "`n📁 Published files in ${publishFolder}:"
try {
    Get-ChildItem -Path $publishFolder | ForEach-Object { Write-Host $_.Name }
} catch {
    Write-Host "⚠️ Could not list files: $_"
}

Write-Host "`n🌐 App is ready at: http://localhost/BlazorCrudApp"
Read-Host "Press Enter to exit..."
