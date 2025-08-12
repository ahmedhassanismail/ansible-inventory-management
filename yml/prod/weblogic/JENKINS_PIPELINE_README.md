# Jenkins Pipeline Integration for WebLogic Upgrade

## Overview

This document describes how to integrate the WebLogic Java upgrade playbook with Jenkins CI/CD pipeline. The pipeline provides a user-friendly interface for executing the Ansible playbook with all required variables.

## 🚀 **Quick Start**

### **1. Basic Jenkins Pipeline Usage**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'OLD_JAVA_VERSION', defaultValue: 'jdk-11.0.12', description: 'Current Java version to replace')
        string(name: 'NEW_JAVA_VERSION', defaultValue: 'jdk-11.0.60', description: 'New Java version to install')
        string(name: 'JAVA_INSTALLER', defaultValue: 'jdk-11.0.60-windows-x64.exe', description: 'Java installer filename')
        string(name: 'JAVA_INSTALL_DIR', defaultValue: 'E:\\jdk-11.0.60', description: 'Java installation directory')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home', description: 'Oracle Home path')
        string(name: 'BACKUP_DIR', defaultValue: 'E:\\Oracle\\backup', description: 'Backup directory path')
        string(name: 'JAVA_SOURCE_DIR', defaultValue: 'E:\\Java_source', description: 'Java source directory')
        choice(name: 'TARGET_HOSTS', choices: ['prod_weblogic_win', 'prod_weblogic_medgo', 'prod_weblogic_batch'], description: 'Target host group')
    }
    
    stages {
        stage('Execute WebLogic Upgrade') {
            steps {
                sh """
                    ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \\
                      -e "old_java_version='${params.OLD_JAVA_VERSION}'" \\
                      -e "old_java_version='${params.NEW_JAVA_VERSION}'" \\
                      -e "java_installer='${params.JAVA_INSTALLER}'" \\
                      -e "java_install_dir='${params.JAVA_INSTALL_DIR}'" \\
                      -e "oracle_home='${params.ORACLE_HOME}'" \\
                      -e "backup_dir='${params.BACKUP_DIR}'" \\
                      -e "java_source_dir='${params.JAVA_SOURCE_DIR}'" \\
                      --limit ${params.TARGET_HOSTS} \\
                      -vv
                """
            }
        }
    }
}
```

## 📋 **Required Parameters**

| Parameter | Description | Example | Required |
|-----------|-------------|---------|----------|
| `OLD_JAVA_VERSION` | Current Java version to replace in files | `jdk-11.0.12` | ✅ Yes |
| `NEW_JAVA_VERSION` | New Java version to install | `jdk-11.0.60` | ✅ Yes |
| `JAVA_INSTALLER` | Java installer filename | `jdk-11.0.60-windows-x64.exe` | ✅ Yes |
| `JAVA_INSTALL_DIR` | Java installation directory on Windows | `E:\jdk-11.0.60` | ✅ Yes |
| `ORACLE_HOME` | Oracle Home directory path | `E:\Oracle\Middleware\Oracle_Home` | ✅ Yes |
| `BACKUP_DIR` | Backup directory for WebLogic files | `E:\Oracle\backup` | ✅ Yes |
| `JAVA_SOURCE_DIR` | Java source directory on Windows | `E:\Java_source` | ✅ Yes |
| `TARGET_HOSTS` | Target host group from inventory | `prod_weblogic_win` | ✅ Yes |

## 🔧 **Advanced Jenkins Pipeline**

### **Full Pipeline with Validation and Error Handling**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'OLD_JAVA_VERSION', defaultValue: 'jdk-11.0.12', description: 'Current Java version to replace')
        string(name: 'NEW_JAVA_VERSION', defaultValue: 'jdk-11.0.60', description: 'New Java version to install')
        string(name: 'JAVA_INSTALLER', defaultValue: 'jdk-11.0.60-windows-x64.exe', description: 'Java installer filename')
        string(name: 'JAVA_INSTALL_DIR', defaultValue: 'E:\\jdk-11.0.60', description: 'Java installation directory')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home', description: 'Oracle Home path')
        string(name: 'BACKUP_DIR', defaultValue: 'E:\\Oracle\\backup', description: 'Backup directory path')
        string(name: 'JAVA_SOURCE_DIR', defaultValue: 'E:\\Java_source', description: 'Java source directory')
        choice(name: 'TARGET_HOSTS', choices: ['prod_weblogic_win', 'prod_weblogic_medgo', 'prod_weblogic_batch'], description: 'Target host group')
        booleanParam(name: 'DRY_RUN', defaultValue: false, description: 'Run in check mode (dry run)')
        booleanParam(name: 'VERBOSE', defaultValue: true, description: 'Enable verbose output')
    }
    
    stages {
        stage('Validate Parameters') {
            steps {
                script {
                    // Validate required parameters
                    def requiredParams = [
                        'OLD_JAVA_VERSION', 'NEW_JAVA_VERSION', 'JAVA_INSTALLER', 
                        'JAVA_INSTALL_DIR', 'ORACLE_HOME', 'BACKUP_DIR', 'JAVA_SOURCE_DIR'
                    ]
                    
                    requiredParams.each { param ->
                        if (!params[param]?.trim()) {
                            error "Parameter ${param} is required!"
                        }
                    }
                    
                    echo "All required parameters provided:"
                    requiredParams.each { param ->
                        echo "${param}: ${params[param]}"
                    }
                }
            }
        }
        
        stage('Pre-Execution Check') {
            steps {
                script {
                    echo """
                    ===== PRE-EXECUTION SUMMARY =====
                    Target Environment: PROD
                    Java Version Update: ${params.OLD_JAVA_VERSION} → ${params.NEW_JAVA_VERSION}
                    Target Hosts: ${params.TARGET_HOSTS}
                    Oracle Home: ${params.ORACLE_HOME}
                    Backup Directory: ${params.BACKUP_DIR}
                    Java Installer: ${params.JAVA_INSTALLER}
                    =================================
                    """
                }
            }
        }
        
        stage('Execute WebLogic Upgrade') {
            steps {
                script {
                    def checkMode = params.DRY_RUN ? '--check' : ''
                    def verboseFlag = params.VERBOSE ? '-vv' : ''
                    
                    def ansibleCmd = """
                        ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \\
                          -e "old_java_version='${params.OLD_JAVA_VERSION}'" \\
                          -e "new_java_version='${params.NEW_JAVA_VERSION}'" \\
                          -e "java_installer='${params.JAVA_INSTALLER}'" \\
                          -e "java_install_dir='${params.JAVA_INSTALL_DIR}'" \\
                          -e "oracle_home='${params.ORACLE_HOME}'" \\
                          -e "backup_dir='${params.BACKUP_DIR}'" \\
                          -e "java_source_dir='${params.JAVA_SOURCE_DIR}'" \\
                          --limit ${params.TARGET_HOSTS} \\
                          ${checkMode} \\
                          ${verboseFlag}
                    """.stripIndent()
                    
                    echo "Executing Ansible command:"
                    echo ansibleCmd
                    
                    sh ansibleCmd
                }
            }
        }
        
        stage('Post-Execution Summary') {
            steps {
                script {
                    echo """
                    ===== WEBLOGIC UPGRADE COMPLETED =====
                    Old Java Version: ${params.OLD_JAVA_VERSION}
                    New Java Version: ${params.NEW_JAVA_VERSION}
                    Target Hosts: ${params.TARGET_HOSTS}
                    Oracle Home: ${params.ORACLE_HOME}
                    Backup Directory: ${params.BACKUP_DIR}
                    Execution Time: ${new Date().format("yyyy-MM-dd HH:mm:ss")}
                    =========================================
                    """
                }
            }
        }
    }
    
    post {
        always {
            echo "WebLogic upgrade pipeline completed"
        }
        success {
            echo "✅ WebLogic upgrade completed successfully!"
        }
        failure {
            echo "❌ WebLogic upgrade failed!"
        }
    }
}
```

## 🎯 **Common Usage Scenarios**

### **Scenario 1: Update JDK 11.0.12 to 11.0.60**
```
OLD_JAVA_VERSION: jdk-11.0.12
NEW_JAVA_VERSION: jdk-11.0.60
JAVA_INSTALLER: jdk-11.0.60-windows-x64.exe
JAVA_INSTALL_DIR: E:\jdk-11.0.60
TARGET_HOSTS: prod_weblogic_win
```

### **Scenario 2: Update JDK 8 to JDK 11**
```
OLD_JAVA_VERSION: jdk-8.0.441
NEW_JAVA_VERSION: jdk-11.0.60
JAVA_INSTALLER: jdk-11.0.60-windows-x64.exe
JAVA_INSTALL_DIR: E:\jdk-11.0.60
TARGET_HOSTS: prod_weblogic_medgo
```

### **Scenario 3: Update to JDK 17**
```
OLD_JAVA_VERSION: jdk-11.0.60
NEW_JAVA_VERSION: jdk-17.0.9
JAVA_INSTALLER: jdk-17.0.9-windows-x64.exe
JAVA_INSTALL_DIR: E:\jdk-17.0.9
TARGET_HOSTS: prod_weblogic_batch
```

## 📝 **Manual Ansible Command Line**

If you prefer to run the Ansible command manually (outside of Jenkins):

```bash
# Basic command structure
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'" \
  --limit prod_weblogic_win \
  -vv
```

## 🔍 **Pipeline Features**

### **Parameter Validation**
- ✅ Checks all required parameters are provided
- ✅ Validates parameter values before execution
- ✅ Clear error messages for missing parameters

### **Execution Options**
- 🔍 **Dry Run Mode**: Use `DRY_RUN=true` to preview changes without making them
- 📊 **Verbose Output**: Enable detailed logging with `VERBOSE=true`
- 🎯 **Host Targeting**: Select specific host groups to upgrade

### **Logging & Monitoring**
- 📝 **Pre-execution Summary**: Shows what will be executed
- 📊 **Real-time Output**: Live Ansible execution logs
- 📋 **Post-execution Summary**: Confirms completion with details

## 🚨 **Troubleshooting**

### **Common Pipeline Issues**

1. **Parameter Validation Failed**
   ```
   Parameter OLD_JAVA_VERSION is required!
   ```
   **Solution**: Ensure all required parameters are filled in Jenkins UI

2. **Ansible Command Failed**
   ```
   ansible-playbook: command not found
   ```
   **Solution**: Ensure Ansible is installed on Jenkins agent

3. **Inventory File Not Found**
   ```
   ERROR! The file inventory was not found
   ```
   **Solution**: Ensure inventory file exists in Jenkins workspace

4. **Permission Denied**
   ```
   Permission denied (publickey,password)
   ```
   **Solution**: Check SSH key configuration for target hosts

### **Debug Commands**

```bash
# Test connectivity to target hosts
ansible -i inventory prod_weblogic_win -m ping

# Check host facts
ansible -i inventory prod_weblogic_win -m setup

# Validate playbook syntax
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml --syntax-check
```

## 📚 **Additional Resources**

- **Main Playbook**: `yml/prod/weblogic/upgrade_Java_weblogic.yml`
- **Configuration Examples**: `yml/prod/weblogic/java_version_update.yml`
- **Rollback Playbook**: `yml/prod/weblogic/rollback_weblogic.yml`
- **Main README**: `yml/prod/weblogic/README.md`

## 🎉 **Success Indicators**

When the pipeline completes successfully, you should see:

1. ✅ **All stages completed** without errors
2. 📊 **Post-execution summary** with execution details
3. 📝 **Ansible output** showing successful file updates
4. 🔄 **Backup confirmation** for all WebLogic files
5. ☕ **Java installation** confirmation
6. 🌐 **WebLogic version** verification

## 📞 **Support**

For issues or questions:
1. Check the Jenkins console output for detailed error messages
2. Review the Ansible playbook logs
3. Verify all parameters are correctly set
4. Ensure target hosts are accessible from Jenkins agent

---

**Remember**: Always test with `DRY_RUN=true` first to preview changes before executing in production! 🚀
