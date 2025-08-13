# Business Line Playbooks with Ansible Vault - Usage Guide

## Overview

This guide explains how to use business line-specific Ansible playbooks with Ansible Vault for secure credential management. This approach allows you to:

- **Target specific business lines** (MedGo, External Reports, Batch, etc.)
- **Maintain security** with encrypted credentials
- **Automate deployments** using vault password files
- **Isolate changes** to specific business applications

## Directory Structure

```
yml/
├── medgo/                    # MedGo Business Line
│   ├── prod/
│   │   └── weblogic/
│   │       ├── upgrade_Java_weblogic.yml
│   │       ├── upgrade_opatch_windows.yml
│   │       └── Apply_Patch_weblogic.yml
│   ├── dr/
│   ├── dev/
│   ├── sit/
│   ├── test/
│   └── uat/
├── external_reports/         # External Reports Business Line
├── batch/                    # Batch Processing Business Line
├── ncci/                     # NCCI Business Line
├── wasel/                    # Wasel Business Line
├── docmosis/                 # Docmosis Business Line
├── digital/                  # Digital Business Line
├── filenet/                  # FileNet Business Line
├── marine/                   # Marine Business Line
└── ebusiness/                # eBusiness Business Line
```

## Prerequisites

### 1. Vault Password File Setup

```bash
# Create vault password file
echo "your_actual_vault_password" > .vault_pass

# Set restrictive permissions (Linux/Mac)
chmod 600 .vault_pass

# On Windows, ensure only authorized users can access
```

### 2. Encrypt Vault Files

```bash
# Encrypt the Windows vault file
ansible-vault encrypt group_vars/windows_vault.yml

# Verify encryption
ansible-vault view group_vars/windows_vault.yml
```

## Usage Examples

### **MedGo Business Line - Java Upgrade**

#### **Command Line Execution**
```bash
# Execute MedGo Java upgrade in PROD environment
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

#### **DR Environment**
```bash
# Execute MedGo Java upgrade in DR environment
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/medgo/dr/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

### **External Reports Business Line - OPatch Upgrade**

```bash
# Execute External Reports OPatch upgrade in PROD
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/external_reports/prod/weblogic/upgrade_opatch_windows.yml \
  -e "local_opatch_jar='/home/appadmin/OPatch/6880880/opatch_generic.jar'" \
  -e "opatch_temp_dir='E:\\OPatch_source'" \
  -e "java_path='E:\\jdk1.8.0_441\\bin\\java.exe'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'"
```

### **Batch Business Line - WebLogic Patch**

```bash
# Execute Batch WebLogic patch in PROD
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/batch/prod/weblogic/Apply_Patch_weblogic.yml \
  -e "patch_number='35247514'" \
  -e "patch_file='p35247514_122130_Generic.zip'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "patch_local_path='/home/appadmin/patches/p35247514_122130_Generic.zip'" \
  -e "patch_remote_path='E:\\Oracle\\patches\\p35247514_122130_Generic.zip'" \
  -e "patch_extract_path='E:\\Oracle\\Middleware\\patches\\35247514'"
```

## Jenkins Pipeline Integration

### **MedGo Business Line Pipeline**

```groovy
pipeline {
    agent any
    
    environment {
        VAULT_PASSWORD_FILE = '.vault_pass'
        BUSINESS_LINE = 'medgo'
        ENVIRONMENT = 'prod'
    }
    
    parameters {
        string(name: 'OLD_JAVA_VERSION', defaultValue: 'jdk-11.0.12')
        string(name: 'NEW_JAVA_VERSION', defaultValue: 'jdk-11.0.60')
        string(name: 'JAVA_INSTALLER', defaultValue: 'jdk-11.0.60-windows-x64.exe')
        string(name: 'JAVA_INSTALL_DIR', defaultValue: 'E:\\jdk-11.0.60')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home')
        string(name: 'BACKUP_DIR', defaultValue: 'E:\\Oracle\\backup')
        string(name: 'JAVA_SOURCE_DIR', defaultValue: 'E:\\Java_source')
        booleanParam(name: 'DRY_RUN', defaultValue: true)
        booleanParam(name: 'VERBOSE', defaultValue: true)
        booleanParam(name: 'HOST_BY_HOST', defaultValue: true)
    }
    
    stages {
        stage('Validate Parameters') {
            steps {
                script {
                    if (params.OLD_JAVA_VERSION == params.NEW_JAVA_VERSION) {
                        error "Old and new Java versions cannot be the same!"
                    }
                }
            }
        }
        
        stage('Execute MedGo Java Upgrade') {
            steps {
                sh """
                    ansible-playbook --vault-password-file ${VAULT_PASSWORD_FILE} -i inventory \\
                      yml/${BUSINESS_LINE}/${ENVIRONMENT}/weblogic/upgrade_Java_weblogic.yml \\
                      -e "old_java_version='${params.OLD_JAVA_VERSION}'" \\
                      -e "new_java_version='${params.NEW_JAVA_VERSION}'" \\
                      -e "java_installer='${params.JAVA_INSTALLER}'" \\
                      -e "java_install_dir='${params.JAVA_INSTALL_DIR}'" \\
                      -e "oracle_home='${params.ORACLE_HOME}'" \\
                      -e "backup_dir='${params.BACKUP_DIR}'" \\
                      -e "java_source_dir='${params.JAVA_SOURCE_DIR}'" \\
                      --limit prod_weblogic_medgo \\
                      ${params.DRY_RUN ? '--check' : ''} \\
                      ${params.VERBOSE ? '-vv' : ''}
                """
            }
        }
    }
    
    post {
        always {
            echo "MedGo Java upgrade completed for ${ENVIRONMENT} environment"
        }
    }
}
```

### **Multi-Business Line Pipeline**

```groovy
pipeline {
    agent any
    
    environment {
        VAULT_PASSWORD_FILE = '.vault_pass'
    }
    
    parameters {
        choice(name: 'BUSINESS_LINE', choices: ['medgo', 'external_reports', 'batch', 'ncci', 'wasel'])
        choice(name: 'ENVIRONMENT', choices: ['prod', 'dr', 'dev', 'sit', 'test', 'uat'])
        choice(name: 'OPERATION', choices: ['java_upgrade', 'opatch_upgrade', 'patch_application'])
        booleanParam(name: 'DRY_RUN', defaultValue: true)
    }
    
    stages {
        stage('Execute Business Line Operation') {
            steps {
                script {
                    def playbook_path = "yml/${params.BUSINESS_LINE}/${params.ENVIRONMENT}/weblogic/"
                    
                    switch(params.OPERATION) {
                        case 'java_upgrade':
                            sh """
                                ansible-playbook --vault-password-file ${VAULT_PASSWORD_FILE} -i inventory \\
                                  ${playbook_path}upgrade_Java_weblogic.yml \\
                                  -e "old_java_version='jdk-11.0.12'" \\
                                  -e "new_java_version='jdk-11.0.60'" \\
                                  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \\
                                  -e "java_install_dir='E:\\jdk-11.0.60'" \\
                                  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \\
                                  -e "backup_dir='E:\\Oracle\\backup'" \\
                                  -e "java_source_dir='E:\\Java_source'" \\
                                  --limit ${params.ENVIRONMENT}_weblogic_${params.BUSINESS_LINE} \\
                                  ${params.DRY_RUN ? '--check' : ''}
                            """
                            break
                            
                        case 'opatch_upgrade':
                            sh """
                                ansible-playbook --vault-password-file ${VAULT_PASSWORD_FILE} -i inventory \\
                                  ${playbook_path}upgrade_opatch_windows.yml \\
                                  -e "local_opatch_jar='/home/appadmin/OPatch/6880880/opatch_generic.jar'" \\
                                  -e "opatch_temp_dir='E:\\OPatch_source'" \\
                                  -e "java_path='E:\\jdk1.8.0_441\\bin\\java.exe'" \\
                                  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \\
                                  --limit ${params.ENVIRONMENT}_weblogic_${params.BUSINESS_LINE} \\
                                  ${params.DRY_RUN ? '--check' : ''}
                            """
                            break
                            
                        case 'patch_application':
                            sh """
                                ansible-playbook --vault-password-file ${VAULT_PASSWORD_FILE} -i inventory \\
                                  ${playbook_path}Apply_Patch_weblogic.yml \\
                                  -e "patch_number='35247514'" \\
                                  -e "patch_file='p35247514_122130_Generic.zip'" \\
                                  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \\
                                  -e "patch_local_path='/home/appadmin/patches/p35247514_122130_Generic.zip'" \\
                                  -e "patch_remote_path='E:\\Oracle\\patches/p35247514_122130_Generic.zip'" \\
                                  -e "patch_extract_path='E:\\Oracle\\Middleware\\patches\\35247514'" \\
                                  --limit ${params.ENVIRONMENT}_weblogic_${params.BUSINESS_LINE} \\
                                  ${params.DRY_RUN ? '--check' : ''}
                            """
                            break
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "${params.OPERATION} completed for ${params.BUSINESS_LINE} in ${params.ENVIRONMENT} environment"
        }
    }
}
```

## Business Line-Specific Configurations

### **MedGo Business Line**
- **Default Domain**: `medgo_domain`
- **Target Hosts**: `prod_weblogic_medgo`, `dr_weblogic_medgo`, etc.
- **Special Configurations**: MedGo-specific WebLogic settings

### **External Reports Business Line**
- **Default Domain**: `external_reports_domain`
- **Target Hosts**: `prod_weblogic_external_reports`, `dr_weblogic_external_reports`, etc.
- **Special Configurations**: Reporting-specific optimizations

### **Batch Business Line**
- **Default Domain**: `batch_domain`
- **Target Hosts**: `prod_weblogic_batch`, `dr_weblogic_batch`, etc.
- **Special Configurations**: Batch processing optimizations

## Security Considerations

### **Vault Password Management**
- Store vault passwords securely (Jenkins credentials, secure key stores)
- Never hardcode vault passwords in pipelines
- Use environment variables for vault password file paths

### **Business Line Isolation**
- Each business line has its own playbook versions
- Changes are isolated to specific business applications
- Different business lines can have different compliance requirements

### **Access Control**
- Restrict access to business line playbooks based on roles
- Use Jenkins job permissions to control who can execute which business line operations
- Audit all business line deployments

## Troubleshooting

### **Common Issues**

1. **"Vault password is required"**
   - Ensure `--vault-password-file .vault_pass` is included
   - Verify vault file is properly encrypted

2. **"Host group not found"**
   - Check inventory for correct business line host groups
   - Verify host group naming convention: `{env}_weblogic_{business_line}`

3. **"Playbook not found"**
   - Verify business line directory structure
   - Check file paths in Jenkins pipelines

### **Debug Commands**

```bash
# Test vault access
ansible-vault view group_vars/windows_vault.yml

# List business line hosts
ansible -i inventory --list-hosts prod_weblogic_medgo

# Test connectivity to business line hosts
ansible -i inventory prod_weblogic_medgo -m ping --vault-password-file .vault_pass

# Validate playbook syntax
ansible-playbook --vault-password-file .vault_pass -i inventory \
  yml/medgo/prod/weblogic/upgrade_Java_weblogic.yml --syntax-check
```

## Best Practices

### **1. Business Line Organization**
- Keep business line playbooks separate and organized
- Use consistent naming conventions
- Document business line-specific requirements

### **2. Security**
- Always use vault passwords for sensitive operations
- Implement role-based access control
- Audit all business line deployments

### **3. Automation**
- Use Jenkins pipelines for consistent execution
- Implement proper error handling and rollback procedures
- Test business line playbooks in lower environments first

### **4. Documentation**
- Maintain business line-specific documentation
- Document business line dependencies and requirements
- Keep deployment procedures updated

## Next Steps

1. **Complete Business Line Structure**: Create directories for all business lines
2. **Customize Playbooks**: Adapt playbooks for each business line's specific needs
3. **Update Jenkins Pipelines**: Implement business line-specific pipelines
4. **Test and Validate**: Test all business line playbooks in lower environments
5. **Document Procedures**: Create business line-specific deployment guides

---

**Remember**: Business line separation with vault passwords provides both security and operational flexibility!
