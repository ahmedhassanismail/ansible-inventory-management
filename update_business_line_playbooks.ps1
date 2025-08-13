# PowerShell Script to Update All Business Line Playbooks
# This script updates all playbooks with the new vault approach and correct host groups

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

$environments = @("prod", "dr", "dev", "sit", "test", "uat")
$middlewareTypes = @("weblogic", "tomcat", "jboss", "httpd")

Write-Host "Starting Business Line Playbook Updates..." -ForegroundColor Green

foreach ($businessLine in $businessLines) {
    foreach ($env in $environments) {
        foreach ($middleware in $middlewareTypes) {
            $playbookPath = "yml/$businessLine/$env/$middleware"
            
            if (Test-Path $playbookPath) {
                Write-Host "Processing: $playbookPath" -ForegroundColor Yellow
                
                # Get all YAML files in the directory
                $yamlFiles = Get-ChildItem -Path $playbookPath -Filter "*.yml"
                
                foreach ($file in $yamlFiles) {
                    $filePath = $file.FullName
                    Write-Host "  Updating: $($file.Name)" -ForegroundColor Cyan
                    
                    # Read file content
                    $content = Get-Content -Path $filePath -Raw
                    
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
                    $content = $businessLineDisplay
                    
                    # Update default domain names
                    $defaultDomain = "${businessLine}_domain"
                    $content = $content -replace "medgo_domain", $defaultDomain
                    $content = $content -replace "external_reports_domain", $defaultDomain
                    
                    # Update vault password examples
                    $content = $content -replace "ansible-playbook -i inventory", "ansible-playbook --vault-password-file .vault_pass -i inventory"
                    
                    # Write updated content back to file
                    Set-Content -Path $filePath -Value $content -NoNewline
                    
                    Write-Host "    ✓ Updated: $($file.Name)" -ForegroundColor Green
                }
            }
        }
    }
}

Write-Host "Business Line Playbook Updates Completed!" -ForegroundColor Green
Write-Host "All playbooks now use the new vault approach and correct host groups." -ForegroundColor Green
