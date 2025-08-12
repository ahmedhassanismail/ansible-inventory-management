# Jenkins Pipelines for WebLogic Operations

## Overview

This document describes the Jenkins CI/CD pipelines available for WebLogic operations:
1. **Java Upgrade Pipeline** - Updates Java versions in WebLogic configuration files
2. **Patch Application Pipeline** - Applies WebLogic patches using OPatch

## 🚀 **Available Pipelines**

### **1. WebLogic Java Upgrade Pipeline**
- **File**: `Jenkinsfile`
- **Purpose**: Upgrade Java versions in WebLogic configuration files
- **Target**: Windows WebLogic servers

### **2. WebLogic Patch Application Pipeline**
- **File**: `Jenkinsfile_Patch`
- **Purpose**: Apply WebLogic patches using OPatch
- **Target**: Windows WebLogic servers

## 📋 **Pipeline Parameters Comparison**

| Parameter | Java Upgrade | Patch Application | Description |
|-----------|--------------|-------------------|-------------|
| `OLD_JAVA_VERSION` | ✅ Required | ❌ N/A | Current Java version to replace |
| `NEW_JAVA_VERSION` | ✅ Required | ❌ N/A | New Java version to install |
| `JAVA_INSTALLER` | ✅ Required | ❌ N/A | Java installer filename |
| `JAVA_INSTALL_DIR` | ✅ Required | ❌ N/A | Java installation directory |
| `PATCH_NUMBER` | ❌ N/A | ✅ Required | Patch identification number |
| `PATCH_FILE` | ❌ N/A | ✅ Required | Patch ZIP file name |
| `ORACLE_HOME` | ✅ Required | ✅ Required | Oracle Home directory path |
| `BACKUP_DIR` | ✅ Required | ❌ N/A | Backup directory for WebLogic files |
| `JAVA_SOURCE_DIR` | ✅ Required | ❌ N/A | Java source directory on Windows |
| `PATCH_LOCAL_PATH` | ❌ N/A | ✅ Required | Source patch file path on Ansible |
| `PATCH_REMOTE_PATH` | ❌ N/A | ✅ Required | Destination patch file path on Windows |
| `PATCH_EXTRACT_PATH` | ❌ N/A | ✅ Required | Patch extraction directory |
| `TARGET_HOSTS` | ✅ Required | ✅ Required | Target host group from inventory |
| `DRY_RUN` | ✅ Optional | ✅ Optional | Run in check mode (dry run) |
| `VERBOSE` | ✅ Optional | ✅ Optional | Enable verbose output |

## 🔧 **Pipeline Features**

### **Common Features**
- ✅ **Parameter Validation**: Checks all required parameters are provided
- 🔍 **Dry Run Mode**: Preview changes without making them
- 📊 **Verbose Output**: Detailed logging options
- 🎯 **Host Targeting**: Select specific host groups
- 📝 **Pre/Post Execution Summary**: Clear operation overview
- 🚨 **Error Handling**: Comprehensive failure reporting

### **Java Upgrade Specific**
- ☕ **Java Version Management**: Update Java versions in WebLogic files
- 💾 **Automatic Backup**: Creates timestamped backups before changes
- 🔄 **File Replacement**: Updates multiple WebLogic configuration files
- 📦 **Java Installation**: Uninstalls old Java and installs new version

### **Patch Application Specific**
- 🔧 **OPatch Integration**: Uses Oracle OPatch for patch application
- 📦 **File Transfer**: Copies patch files from Ansible to Windows
- 📂 **Directory Management**: Creates necessary patch directories
- 🔍 **Patch Verification**: Shows extracted patch contents

## 📖 **Usage Examples**

### **Java Upgrade Pipeline**

#### **Basic Usage**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'OLD_JAVA_VERSION', defaultValue: 'jdk-11.0.12')
        string(name: 'NEW_JAVA_VERSION', defaultValue: 'jdk-11.0.60')
        string(name: 'JAVA_INSTALLER', defaultValue: 'jdk-11.0.60-windows-x64.exe')
        string(name: 'JAVA_INSTALL_DIR', defaultValue: 'E:\\jdk-11.0.60')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home')
        string(name: 'BACKUP_DIR', defaultValue: 'E:\\Oracle\\backup')
        string(name: 'JAVA_SOURCE_DIR', defaultValue: 'E:\\Java_source')
        choice(name: 'TARGET_HOSTS', choices: ['prod_weblogic_win', 'prod_weblogic_medgo'])
        booleanParam(name: 'DRY_RUN', defaultValue: false)
        booleanParam(name: 'VERBOSE', defaultValue: true)
    }
    
    stages {
        stage('Execute WebLogic Upgrade') {
            steps {
                sh """
                    ansible-playbook -i inventory upgrade_Java_weblogic.yml \\
                      -e "old_java_version='${params.OLD_JAVA_VERSION}'" \\
                      -e "new_java_version='${params.NEW_JAVA_VERSION}'" \\
                      -e "java_installer='${params.JAVA_INSTALLER}'" \\
                      -e "java_install_dir='${params.JAVA_INSTALL_DIR}'" \\
                      -e "oracle_home='${params.ORACLE_HOME}'" \\
                      -e "backup_dir='${params.BACKUP_DIR}'" \\
                      -e "java_source_dir='${params.JAVA_SOURCE_DIR}'" \\
                      --limit ${params.TARGET_HOSTS} \\
                      ${params.DRY_RUN ? '--check' : ''} \\
                      ${params.VERBOSE ? '-vv' : ''}
                """
            }
        }
    }
}
```

### **Patch Application Pipeline**

#### **Basic Usage**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'PATCH_NUMBER', defaultValue: '35247514')
        string(name: 'PATCH_FILE', defaultValue: 'p35247514_122130_Generic.zip')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home')
        string(name: 'PATCH_LOCAL_PATH', defaultValue: '/home/appadmin/patches/p35247514_122130_Generic.zip')
        string(name: 'PATCH_REMOTE_PATH', defaultValue: 'E:\\Oracle\\patches\\p35247514_122130_Generic.zip')
        string(name: 'PATCH_EXTRACT_PATH', defaultValue: 'E:\\Oracle\\Middleware\\patches\\35247514')
        choice(name: 'TARGET_HOSTS', choices: ['prod_weblogic_win', 'prod_weblogic_medgo'])
        booleanParam(name: 'DRY_RUN', defaultValue: false)
        booleanParam(name: 'VERBOSE', defaultValue: true)
    }
    
    stages {
        stage('Execute WebLogic Patch') {
            steps {
                sh """
                    ansible-playbook -i inventory Apply_Patch_weblogic.yml \\
                      -e "patch_number='${params.PATCH_NUMBER}'" \\
                      -e "patch_file='${params.PATCH_FILE}'" \\
                      -e "oracle_home='${params.ORACLE_HOME}'" \\
                      -e "patch_local_path='${params.PATCH_LOCAL_PATH}'" \\
                      -e "patch_remote_path='${params.PATCH_REMOTE_PATH}'" \\
                      -e "patch_extract_path='${params.PATCH_EXTRACT_PATH}'" \\
                      --limit ${params.TARGET_HOSTS} \\
                      ${params.DRY_RUN ? '--check' : ''} \\
                      ${params.VERBOSE ? '-vv' : ''}
                """
            }
        }
    }
}
```

## 🎯 **Common Usage Scenarios**

### **Scenario 1: Java Version Update**
```
OLD_JAVA_VERSION: jdk-11.0.12
NEW_JAVA_VERSION: jdk-11.0.60
JAVA_INSTALLER: jdk-11.0.60-windows-x64.exe
JAVA_INSTALL_DIR: E:\jdk-11.0.60
TARGET_HOSTS: prod_weblogic_win
DRY_RUN: true (first run to test)
```

### **Scenario 2: WebLogic Patch Application**
```
PATCH_NUMBER: 35247514
PATCH_FILE: p35247514_122130_Generic.zip
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
TARGET_HOSTS: prod_weblogic_medgo
DRY_RUN: true (first run to test)
```

## 🔍 **Pipeline Execution Flow**

### **Stage 1: Validate Parameters**
- Checks all required parameters are provided
- Shows clear error messages for missing parameters
- Displays all provided parameter values

### **Stage 2: Pre-Execution Summary**
- Shows what will be executed
- Displays target environment and parameters
- Confirms dry run mode status

### **Stage 3: Execute Operation**
- Runs the appropriate Ansible playbook
- Passes all parameters to the playbook
- Shows real-time execution output

### **Stage 4: Post-Execution Summary**
- Confirms operation completion
- Shows execution details and timing
- Provides success/failure status

## 🚨 **Troubleshooting**

### **Common Pipeline Issues**

1. **Parameter Validation Failed**
   ```
   Parameter PATCH_NUMBER is required!
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
ansible-playbook -i inventory upgrade_Java_weblogic.yml --syntax-check
ansible-playbook -i inventory Apply_Patch_weblogic.yml --syntax-check
```

## 📚 **File Structure**

```
yml/prod/weblogic/
├── upgrade_Java_weblogic.yml      # Java upgrade playbook
├── Apply_Patch_weblogic.yml       # Patch application playbook
├── Jenkinsfile                     # Java upgrade pipeline
├── Jenkinsfile_Patch              # Patch application pipeline
├── java_version_update.yml         # Java upgrade configuration
├── patch_config.yml               # Patch application configuration
├── README.md                      # Java upgrade documentation
├── PATCH_README.md                # Patch application documentation
└── JENKINS_PIPELINES_README.md    # This file
```

## 🎉 **Success Indicators**

### **Java Upgrade Pipeline**
1. ✅ **All stages completed** without errors
2. 📊 **Post-execution summary** with execution details
3. 📝 **Ansible output** showing successful file updates
4. 🔄 **Backup confirmation** for all WebLogic files
5. ☕ **Java installation** confirmation
6. 🌐 **WebLogic version** verification

### **Patch Application Pipeline**
1. ✅ **All stages completed** without errors
2. 📊 **Post-execution summary** with execution details
3. 📦 **Patch file transfer** confirmation
4. 📂 **Patch extraction** success
5. 🔧 **OPatch application** without errors
6. 📋 **Detailed execution summary** provided

## 📞 **Support**

For issues or questions:
1. Check the Jenkins console output for detailed error messages
2. Review the Ansible playbook logs
3. Verify all parameters are correctly set
4. Ensure target hosts are accessible from Jenkins agent
5. Test with `DRY_RUN=true` first to preview changes

---

**Remember**: Always test with `DRY_RUN=true` first to preview changes before executing in production! 🚀
