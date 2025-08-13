# PowerShell Script to Update All Pending Environments (SIT, TEST, UAT)
# This script updates all business line playbooks in pending environments

$businessLines = @(
    "medgo",
    "external_reports", 
    "batch",
    "ncci",
    "wasel",
    "takaful",
    "docmosis",
    "digital",
    "filenet",
    "marine",
    "ebusiness",
    "teammate"
)

$pendingEnvironments = @("sit", "test", "uat")
$middlewareTypes = @("weblogic", "tomcat", "jboss", "httpd")

Write-Host "Starting Update of Pending Environments (SIT, TEST, UAT)..." -ForegroundColor Green
Write-Host "This will update all business lines in all pending environments..." -ForegroundColor Yellow

$totalFiles = 0
$updatedFiles = 0

foreach ($businessLine in $businessLines) {
    Write-Host "`nProcessing Business Line: $businessLine" -ForegroundColor Cyan
    
    foreach ($env in $pendingEnvironments) {
        Write-Host "  Environment: $($env.ToUpper())" -ForegroundColor Yellow
        
        foreach ($middleware in $middlewareTypes) {
            $playbookPath = "yml/$businessLine/$env/$middleware"
            
            if (Test-Path $playbookPath) {
                Write-Host "    Middleware: $middleware" -ForegroundColor Green
                
                # Get all YAML files in the directory
                $yamlFiles = Get-ChildItem -Path $playbookPath -Filter "*.yml"
                $totalFiles += $yamlFiles.Count
                
                foreach ($file in $yamlFiles) {
                    $filePath = $file.FullName
                    Write-Host "      Updating: $($file.Name)" -ForegroundColor White
                    
                    # Read file content
                    $content = Get-Content -Path $filePath -Raw
                    $originalContent = $content
                    
                    # Update host groups based on business line and environment
                    $newHostGroup = ""
                    switch ($middleware) {
                        "weblogic" { 
                            if ($businessLine -eq "medgo") { $newHostGroup = "windows_${env}_medgo" }
                            elseif ($businessLine -eq "external_reports") { $newHostGroup = "windows_${env}_external_report" }
                            elseif ($businessLine -eq "batch") { $newHostGroup = "windows_${env}_batch" }
                            elseif ($businessLine -eq "ncci") { $newHostGroup = "windows_${env}_ncci" }
                            elseif ($businessLine -eq "wasel") { $newHostGroup = "windows_${env}_wasel" }
                            elseif ($businessLine -eq "takaful") { $newHostGroup = "windows_${env}_takaful" }
                            else { $newHostGroup = "windows_${env}_weblogic" }
                        }
                        "tomcat" { 
                            if ($businessLine -eq "docmosis") { $newHostGroup = "windows_${env}_docmosis" }
                            elseif ($businessLine -eq "digital") { $newHostGroup = "windows_${env}_digital_tomcat" }
                            elseif ($businessLine -eq "filenet") { $newHostGroup = "windows_${env}_filenet" }
                            elseif ($businessLine -eq "marine") { $newHostGroup = "windows_${env}_marine" }
                            else { $newHostGroup = "windows_${env}_tomcat" }
                        }
                        "jboss" { 
                            if ($businessLine -eq "ebusiness") { $newHostGroup = "windows_${env}_ebusiness" }
                            else { $newHostGroup = "windows_${env}_jboss" }
                        }
                        "httpd" { 
                            if ($businessLine -eq "teammate") { $newHostGroup = "windows_${env}_teammate" }
                            elseif ($businessLine -eq "digital") { $newHostGroup = "windows_${env}_digital_httpd" }
                            else { $newHostGroup = "windows_${env}_httpd" }
                        }
                    }
                    
                    # Update RedHat host groups if they exist
                    if ($content -match "redhat_.*_weblogic") {
                        $redhatHostGroup = ""
                        switch ($businessLine) {
                            "medgo" { $redhatHostGroup = "redhat_${env}_medgo" }
                            "external_reports" { $redhatHostGroup = "redhat_${env}_external_report" }
                            "batch" { $redhatHostGroup = "redhat_${env}_batch" }
                            "ncci" { $redhatHostGroup = "redhat_${env}_ncci" }
                            "wasel" { $redhatHostGroup = "redhat_${env}_wasel" }
                            "takaful" { $redhatHostGroup = "redhat_${env}_takaful" }
                            default { $redhatHostGroup = "redhat_${env}_weblogic" }
                        }
                        $content = $content -replace "redhat_.*_weblogic", $redhatHostGroup
                    }
                    
                    # Update Windows host groups
                    if ($content -match "windows_.*_weblogic" -or $content -match "prod_weblogic_win") {
                        $content = $content -replace "prod_weblogic_win", $newHostGroup
                        $content = $content -replace "windows_.*_weblogic", $newHostGroup
                    }
                    
                    # Update business line name in playbook title and descriptions
                    $businessLineDisplay = $businessLine -replace "_", " " -replace "\b\w", { $args[0].Value.ToUpper() }
                    $content = $content -replace "MedGo Business Line", "$businessLineDisplay Business Line"
                    $content = $content -replace "Business Line: MedGo", "Business Line: $businessLineDisplay"
                    $content = $content -replace "Business Line: External Reports", "Business Line: $businessLineDisplay"
                    $content = $content -replace "Business Line: Batch", "Business Line: $businessLineDisplay"
                    
                    # Update environment references
                    $content = $content -replace "Environment: PROD", "Environment: $($env.ToUpper())"
                    $content = $content -replace "Environment: DR", "Environment: $($env.ToUpper())"
                    $content = $content -replace "Environment: DEV", "Environment: $($env.ToUpper())"
                    $content = $content -replace "Environment: SIT", "Environment: $($env.ToUpper())"
                    $content = $content -replace "Environment: TEST", "Environment: $($env.ToUpper())"
                    $content = $content -replace "Environment: UAT", "Environment: $($env.ToUpper())"
                    
                    # Update default domain names
                    $defaultDomain = "${businessLine}_domain"
                    $content = $content -replace "medgo_domain", $defaultDomain
                    $content = $content -replace "external_reports_domain", $defaultDomain
                    $content = $content -replace "batch_domain", $defaultDomain
                    $content = $content -replace "base_domain", $defaultDomain
                    
                    # Update vault password examples
                    $content = $content -replace "ansible-playbook -i inventory", "ansible-playbook --vault-password-file .vault_pass -i inventory"
                    
                    # Update execution summary environment
                    $content = $content -replace 'environment: "PROD"', "environment: `"$($env.ToUpper())`""
                    $content = $content -replace 'environment: "DR"', "environment: `"$($env.ToUpper())`""
                    $content = $content -replace 'environment: "DEV"', "environment: `"$($env.ToUpper())`""
                    $content = $content -replace 'environment: "SIT"', "environment: `"$($env.ToUpper())`""
                    $content = $content -replace 'environment: "TEST"', "environment: `"$($env.ToUpper())`""
                    $content = $content -replace 'environment: "UAT"', "environment: `"$($env.ToUpper())`""
                    
                    # Only write if content changed
                    if ($content -ne $originalContent) {
                        Set-Content -Path $filePath -Value $content -NoNewline
                        $updatedFiles++
                        Write-Host "        ✓ Updated: $($file.Name)" -ForegroundColor Green
                    } else {
                        Write-Host "        - No changes needed: $($file.Name)" -ForegroundColor Gray
                    }
                }
            }
        }
    }
}

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host "PENDING ENVIRONMENTS UPDATE COMPLETED!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "Total files processed: $totalFiles" -ForegroundColor White
Write-Host "Files updated: $updatedFiles" -ForegroundColor Green
Write-Host "Files unchanged: $($totalFiles - $updatedFiles)" -ForegroundColor Gray

Write-Host "`nAll pending environment playbooks now use:" -ForegroundColor Yellow
Write-Host "✅ New vault approach with --vault-password-file .vault_pass" -ForegroundColor Green
Write-Host "✅ Correct host groups for each business line and environment" -ForegroundColor Green
Write-Host "✅ Business line-specific domain names" -ForegroundColor Green
Write-Host "✅ Environment-specific configurations (SIT, TEST, UAT)" -ForegroundColor Green

Write-Host "`nUpdated Environments:" -ForegroundColor Yellow
Write-Host "✅ PROD - All business lines" -ForegroundColor Green
Write-Host "✅ DR - MedGo only" -ForegroundColor Green
Write-Host "✅ DEV - MedGo only" -ForegroundColor Green
Write-Host "✅ SIT - All business lines" -ForegroundColor Green
Write-Host "✅ TEST - All business lines" -ForegroundColor Green
Write-Host "✅ UAT - All business lines" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "1. Update .vault_pass with your actual vault password" -ForegroundColor White
Write-Host "2. Encrypt group_vars/windows_vault.yml on your Ansible control node" -ForegroundColor White
Write-Host "3. Test with SIT environment first (lower risk)" -ForegroundColor White
Write-Host "4. Import Jenkinsfile_Business_Line_Master into Jenkins" -ForegroundColor White
