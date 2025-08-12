# Jenkins Pipelines for WebLogic Operations

## Overview

This document describes the Jenkins CI/CD pipelines available for WebLogic operations:
1. **Java Upgrade Pipeline** - Updates Java versions in WebLogic configuration files
2. **Patch Application Pipeline** - Applies WebLogic patches using OPatch
3. **OPatch Upgrade Pipeline** - Upgrades OPatch tool using opatch_generic.jar

## 🚀 **Available Pipelines**

### **1. WebLogic Java Upgrade Pipeline**
- **File**: `Jenkinsfile`
- **Purpose**: Upgrade Java versions in WebLogic configuration files
- **Target**: Windows WebLogic servers

### **2. WebLogic Patch Application Pipeline**
- **File**: `Jenkinsfile_Patch`
- **Purpose**: Apply WebLogic patches using OPatch
- **Target**: Windows WebLogic servers

### **3. OPatch Upgrade Pipeline**
- **File**: `Jenkinsfile_OPatch_Upgrade`
- **Purpose**: Upgrade OPatch tool using opatch_generic.jar
- **Target**: Windows WebLogic servers

## 📋 **Pipeline Parameters Comparison**

| Parameter | Java Upgrade | Patch Application | OPatch Upgrade | Description |
|-----------|--------------|-------------------|----------------|-------------|
| `OLD_JAVA_VERSION` | ✅ Required | ❌ N/A | ❌ N/A | Current Java version to replace |
| `NEW_JAVA_VERSION` | ✅ Required | ❌ N/A | ❌ N/A | New Java version to install |
| `JAVA_INSTALLER` | ✅ Required | ❌ N/A | ❌ N/A | Java installer filename |
| `JAVA_INSTALL_DIR` | ✅ Required | ❌ N/A | ❌ N/A | Java installation directory |
| `PATCH_NUMBER` | ❌ N/A | ✅ Required | ❌ N/A | Patch identification number |
| `PATCH_FILE` | ❌ N/A | ✅ Required | ❌ N/A | Patch ZIP file name |
| `LOCAL_OPATCH_JAR` | ❌ N/A | ❌ N/A | ✅ Required | Path to OPatch JAR on Ansible |
| `OPATCH_TEMP_DIR` | ❌ N/A | ❌ N/A | ✅ Required | Temp directory on Windows |
| `JAVA_PATH` | ❌ N/A | ❌ N/A | ✅ Required | Java executable path on Windows |
| `ORACLE_HOME` | ✅ Required | ✅ Required | ✅ Required | Oracle Home directory path |
| `BACKUP_DIR` | ✅ Required | ❌ N/A | ❌ N/A | Backup directory for WebLogic files |
| `JAVA_SOURCE_DIR` | ✅ Required | ❌ N/A | ❌ N/A | Java source directory on Windows |
| `PATCH_LOCAL_PATH` | ❌ N/A | ✅ Required | ❌ N/A | Source patch file path on Ansible |
| `PATCH_REMOTE_PATH` | ❌ N/A | ✅ Required | ❌ N/A | Destination patch file path on Windows |
| `PATCH_EXTRACT_PATH` | ❌ N/A | ✅ Required | ❌ N/A | Patch extraction directory |
| `TARGET_HOSTS` | ✅ Required | ✅ Required | ✅ Required | Target host group from inventory |
| `DRY_RUN` | ✅ Optional | ✅ Optional | ✅ Optional | Run in check mode (dry run) |
| `VERBOSE` | ✅ Optional | ✅ Optional | ✅ Optional | Enable verbose output |
| `HOST_BY_HOST` | ✅ Optional | ✅ Optional | ✅ Optional | Execute host by host with user confirmation |

## 🔧 **Pipeline Features**

### **Common Features**
- ✅ **Parameter Validation**: Checks all required parameters are provided
- 🔍 **Dry Run Mode**: Preview changes without making them
- 📊 **Verbose Output**: Detailed logging options
- 🎯 **Host Targeting**: Select specific host groups
- 📝 **Pre/Post Execution Summary**: Clear operation overview
- 🚨 **Error Handling**: Comprehensive failure reporting
- 🚦 **Host-by-Host Execution**: Sequential execution with user control

### **Host-by-Host Execution Features**
- **Sequential Processing**: Execute one host at a time
- **User Confirmation**: Prompt for confirmation before each host (except first)
- **Progress Tracking**: Show current host and total progress
- **Failure Handling**: Ask user to continue or stop on host failures
- **Pause Between Hosts**: 5-second pause for user review
- **Parallel Option**: Fallback to execute all hosts simultaneously

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

### **OPatch Upgrade Specific**
- 🔧 **OPatch Tool Upgrade**: Upgrades the OPatch utility itself
- 📦 **JAR File Management**: Copies and executes opatch_generic.jar
- ☕ **Java Integration**: Uses Java to run OPatch upgrade
- 📊 **Version Verification**: Confirms new OPatch version

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
        booleanParam(name: 'HOST_BY_HOST', defaultValue: true)
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
        booleanParam(name: 'HOST_BY_HOST', defaultValue: true)
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

### **OPatch Upgrade Pipeline**

#### **Basic Usage**
```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'LOCAL_OPATCH_JAR', defaultValue: '/home/appadmin/OPatch/6880880/opatch_generic.jar')
        string(name: 'OPATCH_TEMP_DIR', defaultValue: 'E:\\OPatch_source')
        string(name: 'JAVA_PATH', defaultValue: 'E:\\jdk1.8.0_441\\bin\\java.exe')
        string(name: 'ORACLE_HOME', defaultValue: 'E:\\Oracle\\Middleware\\Oracle_Home')
        choice(name: 'TARGET_HOSTS', choices: ['prod_weblogic_win', 'prod_weblogic_medgo'])
        booleanParam(name: 'DRY_RUN', defaultValue: false)
        booleanParam(name: 'VERBOSE', defaultValue: true)
        booleanParam(name: 'HOST_BY_HOST', defaultValue: true)
    }
    
    stages {
        stage('Execute OPatch Upgrade') {
            steps {
                sh """
                    ansible-playbook -i inventory upgrade_opatch_windows.yml \\
                      -e "local_opatch_jar='${params.LOCAL_OPATCH_JAR}'" \\
                      -e "opatch_temp_dir='${params.OPATCH_TEMP_DIR}'" \\
                      -e "java_path='${params.JAVA_PATH}'" \\
                      -e "oracle_home='${params.ORACLE_HOME}'" \\
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
HOST_BY_HOST: true (execute sequentially)
```

### **Scenario 2: WebLogic Patch Application**
```
PATCH_NUMBER: 35247514
PATCH_FILE: p35247514_122130_Generic.zip
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
TARGET_HOSTS: prod_weblogic_medgo
DRY_RUN: true (first run to test)
HOST_BY_HOST: true (execute sequentially)
```

### **Scenario 3: OPatch Tool Upgrade**
```
LOCAL_OPATCH_JAR: /home/appadmin/OPatch/6880880/opatch_generic.jar
OPATCH_TEMP_DIR: E:\OPatch_source
JAVA_PATH: E:\jdk1.8.0_441\bin\java.exe
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
TARGET_HOSTS: prod_weblogic_win
DRY_RUN: true (first run to test)
HOST_BY_HOST: true (execute sequentially)
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
- Shows host-by-host execution mode

### **Stage 3: Get Host List**
- Retrieves list of hosts from inventory group
- Displays all hosts that will be processed
- Shows total count of hosts

### **Stage 4: Execute Operation**
- **Host-by-Host Mode**: Processes one host at a time with user confirmation
- **Parallel Mode**: Runs all hosts simultaneously
- Shows real-time execution output
- Provides progress tracking

### **Stage 5: Post-Execution Summary**
- Confirms operation completion
- Shows execution details and timing
- Provides success/failure status
- Displays execution mode used

## 🚦 **Host-by-Host Execution Details**

### **How It Works**
1. **Host Discovery**: Automatically discovers all hosts in the target group
2. **Sequential Processing**: Executes one host at a time
3. **User Control**: Prompts for confirmation before each host (except first)
4. **Progress Tracking**: Shows current host number and total count
5. **Failure Handling**: On failure, asks user to continue or stop
6. **Pause Between Hosts**: 5-second pause for user review

### **User Experience**
- **First Host**: Executes automatically without confirmation
- **Subsequent Hosts**: User must click "Proceed with [hostname]" to continue
- **Failure Recovery**: User can choose to continue with next host or stop execution
- **Progress Visibility**: Clear indication of current progress (e.g., "Host 2/5")

### **Benefits**
- **Controlled Execution**: User controls the pace and flow
- **Risk Management**: Can stop execution at any point
- **Monitoring**: Easy to track progress and identify issues
- **Flexibility**: Can continue or stop based on results

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

5. **Host-by-Host Execution Stuck**
   ```
   Waiting for user input...
   ```
   **Solution**: Check Jenkins console for user confirmation prompts

### **Debug Commands**

```bash
# Test connectivity to target hosts
ansible -i inventory prod_weblogic_win -m ping

# Check host facts
ansible -i inventory prod_weblogic_win -m setup

# List hosts in a group
ansible -i inventory prod_weblogic_win --list-hosts

# Validate playbook syntax
ansible-playbook -i inventory upgrade_Java_weblogic.yml --syntax-check
ansible-playbook -i inventory Apply_Patch_weblogic.yml --syntax-check
ansible-playbook -i inventory upgrade_opatch_windows.yml --syntax-check
```

## 📚 **File Structure**

```
yml/prod/weblogic/
├── upgrade_Java_weblogic.yml      # Java upgrade playbook
├── Apply_Patch_weblogic.yml       # Patch application playbook
├── upgrade_opatch_windows.yml     # OPatch upgrade playbook
├── Jenkinsfile                     # Java upgrade pipeline
├── Jenkinsfile_Patch              # Patch application pipeline
├── Jenkinsfile_OPatch_Upgrade     # OPatch upgrade pipeline
├── java_version_update.yml         # Java upgrade configuration
├── patch_config.yml               # Patch application configuration
├── opatch_upgrade_config.yml      # OPatch upgrade configuration
├── README.md                      # Java upgrade documentation
├── PATCH_README.md                # Patch application documentation
├── OPATCH_UPGRADE_README.md       # OPatch upgrade documentation
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
7. 🚦 **Host-by-host execution** completed with user control

### **Patch Application Pipeline**
1. ✅ **All stages completed** without errors
2. 📊 **Post-execution summary** with execution details
3. 📦 **Patch file transfer** confirmation
4. 📂 **Patch extraction** success
5. 🔧 **OPatch application** without errors
6. 📋 **Detailed execution summary** provided
7. 🚦 **Host-by-host execution** completed with user control

### **OPatch Upgrade Pipeline**
1. ✅ **All stages completed** without errors
2. 📊 **Post-execution summary** with execution details
3. 📦 **OPatch JAR copy** confirmation
4. 🔧 **OPatch upgrade** success
5. 📊 **Version verification** successful
6. 📋 **Detailed execution summary** provided
7. 🚦 **Host-by-host execution** completed with user control

## 📞 **Support**

For issues or questions:
1. Check the Jenkins console output for detailed error messages
2. Review the Ansible playbook logs
3. Verify all parameters are correctly set
4. Ensure target hosts are accessible from Jenkins agent
5. Test with `DRY_RUN=true` first to preview changes
6. For host-by-host execution, check for user confirmation prompts

---

**Remember**: Always test with `DRY_RUN=true` first to preview changes before executing in production! 🚀

**Host-by-Host Execution**: Use this mode for controlled, sequential execution with user oversight! 🚦
