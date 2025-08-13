# PowerShell Script to Setup Complete Business Line Structure
# This script creates all business line directories and copies playbooks

Write-Host "Setting up Complete Business Line Structure..." -ForegroundColor Green

# Define business lines and their middleware types
$businessLines = @{
    "medgo" = @("weblogic")
    "external_reports" = @("weblogic")
    "batch" = @("weblogic")
    "ncci" = @("weblogic")
    "wasel" = @("weblogic")
    "takaful" = @("weblogic")
    "docmosis" = @("tomcat")
    "digital" = @("tomcat", "httpd")
    "filenet" = @("tomcat")
    "marine" = @("tomcat")
    "ebusiness" = @("jboss")
    "teammate" = @("httpd")
}

$environments = @("prod", "dr", "dev", "sit", "test", "uat")

# Create directories and copy playbooks
foreach ($businessLine in $businessLines.Keys) {
    foreach ($env in $environments) {
        foreach ($middleware in $businessLines[$businessLine]) {
            $targetPath = "yml/$businessLine/$env/$middleware"
            
            # Create directory if it doesn't exist
            if (!(Test-Path $targetPath)) {
                New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                Write-Host "Created: $targetPath" -ForegroundColor Yellow
            }
            
            # Copy playbooks from prod/weblogic if they exist
            $sourcePath = "yml/prod/weblogic"
            if (Test-Path $sourcePath) {
                $yamlFiles = Get-ChildItem -Path $sourcePath -Filter "*.yml"
                foreach ($file in $yamlFiles) {
                    $targetFile = "$targetPath/$($file.Name)"
                    if (!(Test-Path $targetFile)) {
                        Copy-Item -Path $file.FullName -Destination $targetFile -Force
                        Write-Host "  Copied: $($file.Name)" -ForegroundColor Cyan
                    }
                }
            }
        }
    }
}

Write-Host "`nBusiness Line Structure Setup Completed!" -ForegroundColor Green
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Update .vault_pass with your actual vault password" -ForegroundColor White
Write-Host "2. Encrypt group_vars/windows_vault.yml on your Ansible control node" -ForegroundColor White
Write-Host "3. Test with a simple playbook execution" -ForegroundColor White
Write-Host "4. Import Jenkinsfile_Business_Line_Master into Jenkins" -ForegroundColor White

Write-Host "`nDirectory Structure Created:" -ForegroundColor Green
Get-ChildItem -Path "yml" -Recurse -Directory | Sort-Object FullName | ForEach-Object {
    $relativePath = $_.FullName.Replace((Get-Location).Path, "").TrimStart("\")
    Write-Host "  $relativePath" -ForegroundColor White
}
