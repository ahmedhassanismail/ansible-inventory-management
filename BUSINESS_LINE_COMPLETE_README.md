# Complete Business Line Ansible Structure with Vault Integration

## Overview

This repository contains a comprehensive Ansible infrastructure organized by business lines, environments, and middleware types. All sensitive credentials are managed through Ansible Vault for secure operations.

## 🏗️ Directory Structure

```
yml/
├── medgo/                    # MedGo Business Line
│   ├── prod/weblogic/       # Production WebLogic servers
│   ├── dr/weblogic/         # Disaster Recovery WebLogic servers
│   ├── dev/weblogic/        # Development WebLogic servers
│   ├── sit/weblogic/        # SIT WebLogic servers
│   ├── test/weblogic/       # Test WebLogic servers
│   └── uat/weblogic/        # UAT WebLogic servers
├── external_reports/         # External Reports Business Line
├── batch/                    # Batch Processing Business Line
├── ncci/                     # NCCI Business Line
├── wasel/                    # Wasel Business Line
├── takaful/                 # Takaful Business Line
├── docmosis/                # Docmosis Business Line (Tomcat)
├── digital/                  # Digital Business Line (Tomcat/HTTPD)
├── filenet/                  # FileNet Business Line (Tomcat)
├── marine/                   # Marine Business Line (Tomcat)
├── ebusiness/                # eBusiness Business Line (JBoss)
└── teammate/                 # Teammate Business Line (HTTPD)
```

## 🔐 Security: Ansible Vault Integration

### Vault Files
- `group_vars/windows.yml` - Non-sensitive Windows variables
- `group_vars/windows_vault.yml` - Sensitive Windows variables (encrypted)
- `group_vars/redhat.yml` - RedHat variables
- `.vault_pass` - Vault password file (replace with actual password)

### Encrypting Vault Files
```bash
# On your Ansible control node
ansible-vault encrypt group_vars/windows_vault.yml

# Verify encryption
ansible-vault view group_vars/windows_vault.yml
```

## 🎯 Business Line Host Groups

### WebLogic Business Lines
- `windows_prod_medgo` - MedGo WebLogic servers in PROD
- `windows_prod_external_report` - External Reports WebLogic servers in PROD
- `windows_prod_batch` - Batch WebLogic servers in PROD
- `windows_prod_ncci` - NCCI WebLogic servers in PROD
- `windows_prod_wasel` - Wasel WebLogic servers in PROD
- `windows_prod_takaful` - Takaful WebLogic servers in PROD

### Tomcat Business Lines
- `windows_prod_docmosis` - Docmosis Tomcat servers in PROD
- `windows_prod_digital_tomcat` - Digital Tomcat servers in PROD
- `windows_prod_filenet` - FileNet Tomcat servers in PROD
- `windows_prod_marine` - Marine Tomcat servers in PROD

### JBoss Business Lines
- `windows_prod_ebusiness` - eBusiness JBoss servers in PROD

### HTTPD Business Lines
- `windows_prod_teammate` - Teammate HTTPD servers in PROD
- `windows_prod_digital_httpd` - Digital HTTPD servers in PROD

## 🚀 Usage Examples

### Command Line Execution

#### MedGo Business Line - Java Upgrade
```bash
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/medgo/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

#### External Reports Business Line - OPatch Upgrade
```bash
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/external_reports/prod/weblogic/upgrade_opatch_windows.yml \
  -e "local_opatch_jar='/home/appadmin/OPatch/6880880/opatch_generic.jar'" \
  -e "opatch_temp_dir='E:\\OPatch_source'" \
  -e "java_path='E:\\jdk1.8.0_441\\bin\\java.exe'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'"
```

#### Batch Business Line - WebLogic Patch
```bash
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/batch/prod/weblogic/Apply_Patch_weblogic.yml \
  -e "patch_number='35247514'" \
  -e "patch_file='p35247514_122130_Generic.zip'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "patch_local_path='/home/appadmin/patches/p35247514_122130_Generic.zip'" \
  -e "patch_remote_path='E:\\Oracle\\patches\\p35247514_122130_Generic.zip'" \
  -e "patch_extract_path='E:\\Oracle\\Middleware\\patches\\35247514'"
```

## 🏭 Jenkins Pipeline Integration

### Master Business Line Pipeline
Use `Jenkinsfile_Business_Line_Master` for comprehensive business line operations:

**Features:**
- ✅ **Business Line Selection**: Choose from 12 business lines
- ✅ **Environment Selection**: PROD, DR, DEV, SIT, TEST, UAT
- ✅ **Operation Types**: Java upgrade, OPatch upgrade, patch application
- ✅ **Host-by-Host Execution**: Sequential processing with user confirmation
- ✅ **Vault Integration**: Secure credential management
- ✅ **Parameter Validation**: Comprehensive input validation
- ✅ **Error Handling**: Continue/stop options on failures
- ✅ **30-Minute Pauses**: User review time between hosts

### Pipeline Parameters

#### Business Line Selection
- `BUSINESS_LINE`: medgo, external_reports, batch, ncci, wasel, takaful, docmosis, digital, filenet, marine, ebusiness, teammate

#### Environment Selection
- `ENVIRONMENT`: prod, dr, dev, sit, test, uat

#### Operation Types
- `OPERATION`: java_upgrade, opatch_upgrade, patch_application

#### Java Upgrade Variables
- `OLD_JAVA_VERSION`: Current Java version
- `NEW_JAVA_VERSION`: Target Java version
- `JAVA_INSTALLER`: Installer filename
- `JAVA_INSTALL_DIR`: Installation directory
- `ORACLE_HOME`: Oracle Home path
- `BACKUP_DIR`: Backup directory
- `JAVA_SOURCE_DIR`: Source directory

#### OPatch Upgrade Variables
- `LOCAL_OPATCH_JAR`: OPatch JAR path
- `OPATCH_TEMP_DIR`: Temporary directory
- `JAVA_PATH`: Java executable path
- `ORACLE_HOME`: Oracle Home path

#### Patch Application Variables
- `PATCH_NUMBER`: Patch number
- `PATCH_FILE`: Patch filename
- `PATCH_LOCAL_PATH`: Local patch path
- `PATCH_REMOTE_PATH`: Remote patch path
- `PATCH_EXTRACT_PATH`: Extraction path
- `ORACLE_HOME`: Oracle Home path

#### Execution Control
- `DRY_RUN`: Check mode execution
- `VERBOSE`: Verbose output
- `HOST_BY_HOST`: Sequential execution
- `SKIP_FIRST_CONFIRMATION`: Skip first host confirmation

## 🔧 Available Playbooks

### Java Upgrade Playbooks
- `upgrade_Java_weblogic.yml` - WebLogic Java version upgrade
- Available for all WebLogic business lines

### OPatch Upgrade Playbooks
- `upgrade_opatch_windows.yml` - OPatch version upgrade
- Available for all WebLogic business lines

### Patch Application Playbooks
- `Apply_Patch_weblogic.yml` - WebLogic patch application
- Available for all WebLogic business lines

## 📋 Business Line-Specific Configurations

### MedGo Business Line
- **Default Domain**: `medgo_domain`
- **Target Hosts**: `windows_prod_medgo`, `windows_dr_medgo`, etc.
- **Special Configurations**: MedGo-specific WebLogic settings

### External Reports Business Line
- **Default Domain**: `external_reports_domain`
- **Target Hosts**: `windows_prod_external_report`, `windows_dr_external_report`, etc.
- **Special Configurations**: Reporting-specific optimizations

### Batch Business Line
- **Default Domain**: `batch_domain`
- **Target Hosts**: `windows_prod_batch`, `windows_dr_batch`, etc.
- **Special Configurations**: Batch processing optimizations

### NCCI Business Line
- **Default Domain**: `ncci_domain`
- **Target Hosts**: `windows_prod_ncci`, `windows_dr_ncci`, etc.

### Wasel Business Line
- **Default Domain**: `wasel_domain`
- **Target Hosts**: `windows_prod_wasel`, `windows_dr_wasel`, etc.

### Takaful Business Line
- **Default Domain**: `takaful_domain`
- **Target Hosts**: `windows_prod_takaful`, `windows_dr_takaful`, etc.

### Docmosis Business Line
- **Default Domain**: `docmosis_domain`
- **Target Hosts**: `windows_prod_docmosis`, `windows_dr_docmosis`, etc.
- **Middleware**: Tomcat

### Digital Business Line
- **Default Domain**: `digital_domain`
- **Target Hosts**: `windows_prod_digital_tomcat`, `windows_prod_digital_httpd`, etc.
- **Middleware**: Tomcat (for applications), HTTPD (for web servers)

### FileNet Business Line
- **Default Domain**: `filenet_domain`
- **Target Hosts**: `windows_prod_filenet`, `windows_dr_filenet`, etc.
- **Middleware**: Tomcat

### Marine Business Line
- **Default Domain**: `marine_domain`
- **Target Hosts**: `windows_prod_marine`, `windows_dr_marine`, etc.
- **Middleware**: Tomcat

### eBusiness Business Line
- **Default Domain**: `ebusiness_domain`
- **Target Hosts**: `windows_prod_ebusiness`, `windows_dr_ebusiness`, etc.
- **Middleware**: JBoss

### Teammate Business Line
- **Default Domain**: `teammate_domain`
- **Target Hosts**: `windows_prod_teammate`, `windows_dr_teammate`, etc.
- **Middleware**: HTTPD

## 🛡️ Security Best Practices

### Vault Password Management
- Store vault passwords securely (Jenkins credentials, secure key stores)
- Never hardcode vault passwords in pipelines
- Use environment variables for vault password file paths
- Set restrictive permissions on vault password files

### Business Line Isolation
- Each business line has its own playbook versions
- Changes are isolated to specific business applications
- Different business lines can have different compliance requirements

### Access Control
- Restrict access to business line playbooks based on roles
- Use Jenkins job permissions to control who can execute which business line operations
- Audit all business line deployments

## 🔍 Troubleshooting

### Common Issues

1. **"Vault password is required"**
   - Ensure `--vault-password-file .vault_pass` is included
   - Verify vault file is properly encrypted

2. **"Host group not found"**
   - Check inventory for correct business line host groups
   - Verify host group naming convention: `windows_{env}_{business_line}`

3. **"Playbook not found"**
   - Verify business line directory structure
   - Check file paths in Jenkins pipelines

### Debug Commands

```bash
# Test vault access
ansible-vault view group_vars/windows_vault.yml

# List business line hosts
ansible -i inventory --list-hosts windows_prod_medgo

# Test connectivity to business line hosts
ansible -i inventory windows_prod_medgo -m ping --vault-password-file .vault_pass

# Validate playbook syntax
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/medgo/prod/weblogic/upgrade_Java_weblogic.yml --syntax-check
```

## 📚 Best Practices

### 1. Business Line Organization
- Keep business line playbooks separate and organized
- Use consistent naming conventions
- Document business line-specific requirements

### 2. Security
- Always use vault passwords for sensitive operations
- Implement role-based access control
- Audit all business line deployments

### 3. Automation
- Use Jenkins pipelines for consistent execution
- Implement proper error handling and rollback procedures
- Test business line playbooks in lower environments first

### 4. Documentation
- Maintain business line-specific documentation
- Document business line dependencies and requirements
- Keep deployment procedures updated

## 🚀 Getting Started

### 1. Setup Vault
```bash
# Create vault password file
echo "your_actual_vault_password" > .vault_pass

# Encrypt vault file
ansible-vault encrypt group_vars/windows_vault.yml
```

### 2. Test Configuration
```bash
# Test vault access
ansible-vault view group_vars/windows_vault.yml

# Test connectivity
ansible -i inventory windows_prod_medgo -m ping --vault-password-file .vault_pass
```

### 3. Run First Playbook
```bash
# Execute MedGo Java upgrade in PROD
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/medgo/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

### 4. Use Jenkins Pipeline
- Import `Jenkinsfile_Business_Line_Master` into Jenkins
- Configure vault password file path
- Select business line, environment, and operation
- Execute with host-by-host control

## 📋 Next Steps

1. **Complete Business Line Structure**: Ensure all business lines have complete directory structures
2. **Customize Playbooks**: Adapt playbooks for each business line's specific needs
3. **Update Jenkins Pipelines**: Implement business line-specific pipelines if needed
4. **Test and Validate**: Test all business line playbooks in lower environments
5. **Document Procedures**: Create business line-specific deployment guides

---

**Remember**: Business line separation with vault passwords provides both security and operational flexibility! 🎯🔐
