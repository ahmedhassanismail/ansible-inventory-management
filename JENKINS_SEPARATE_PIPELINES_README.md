# 🚀 **Separate Jenkins Pipelines - Usage Guide**

## 📋 **Overview**

This approach provides **separate Jenkins pipeline files** for each operation type, giving you dedicated pipelines with only the relevant parameters for each operation. Each pipeline is focused on a single operation type with its specific variables.

**Note**: `PLAYBOOK_PATH` and `YAML_FILE` are configured as **environment variables** in each pipeline, allowing you to set them manually in the pipeline configuration for each business line and environment.

## 🔧 **Available Pipeline Files**

| Pipeline File | Operation Type | Description |
|---------------|----------------|-------------|
| `Jenkinsfile_Java_Upgrade` | Java Version Upgrade | Dedicated pipeline for Java version updates |
| `Jenkinsfile_OPatch_Upgrade` | OPatch Upgrade | Dedicated pipeline for OPatch version updates |
| `Jenkinsfile_WebLogic_Patch` | WebLogic Patch Application | Dedicated pipeline for WebLogic patches |

## 📝 **Pipeline-Specific Parameters**

### **1. Java Upgrade Pipeline (`Jenkinsfile_Java_Upgrade`)**

#### **Core Parameters**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `HOST_GROUP` | Target host group | `windows_prod_medgo` |

#### **Environment Variables (Set Manually)**
| Variable | Description | Default |
|----------|-------------|---------|
| `PLAYBOOK_PATH` | Path to playbook directory | `yml/medgo/prod/weblogic` |
| `YAML_FILE` | YAML file name | `upgrade_Java_weblogic.yml` |

#### **Java Upgrade Variables**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `OLD_JAVA_VERSION` | Current Java version | `jdk-11.0.12` |
| `NEW_JAVA_VERSION` | New Java version | `jdk-11.0.60` |
| `JAVA_INSTALLER` | Java installer filename | `jdk-11.0.60-windows-x64.exe` |
| `JAVA_INSTALL_DIR` | Installation directory | `E:\jdk-11.0.60` |
| `ORACLE_HOME` | Oracle Home path | `E:\Oracle\Middleware\Oracle_Home` |
| `BACKUP_DIR` | Backup directory | `E:\Oracle\backup` |
| `JAVA_SOURCE_DIR` | Java source directory | `E:\Java_source` |

### **2. OPatch Upgrade Pipeline (`Jenkinsfile_OPatch_Upgrade`)**

#### **Core Parameters**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `HOST_GROUP` | Target host group | `windows_prod_medgo` |

#### **Environment Variables (Set Manually)**
| Variable | Description | Default |
|----------|-------------|---------|
| `PLAYBOOK_PATH` | Path to playbook directory | `yml/medgo/prod/weblogic` |
| `YAML_FILE` | YAML file name | `upgrade_opatch_windows.yml` |

#### **OPatch Upgrade Variables**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `LOCAL_OPATCH_JAR` | OPatch JAR path on Ansible server | `/home/appadmin/OPatch/6880880/opatch_generic.jar` |
| `OPATCH_TEMP_DIR` | Temp directory on Windows | `E:\OPatch_source` |
| `JAVA_PATH` | Java executable path | `E:\jdk1.8.0_441\bin\java.exe` |
| `ORACLE_HOME` | Oracle Home path | `E:\Oracle\Middleware\Oracle_Home` |

### **3. WebLogic Patch Pipeline (`Jenkinsfile_WebLogic_Patch`)**

#### **Core Parameters**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `HOST_GROUP` | Target host group | `windows_prod_medgo` |

#### **Environment Variables (Set Manually)**
| Variable | Description | Default |
|----------|-------------|---------|
| `PLAYBOOK_PATH` | Path to playbook directory | `yml/medgo/prod/weblogic` |
| `YAML_FILE` | YAML file name | `Apply_Patch_weblogic.yml` |

#### **WebLogic Patch Variables**
| Parameter | Description | Default |
|-----------|-------------|---------|
| `PATCH_NUMBER` | WebLogic patch number | `35247514` |
| `PATCH_FILE` | Patch filename | `p35247514_122130_Generic.zip` |
| `PATCH_LOCAL_PATH` | Patch path on Ansible server | `/home/appadmin/patches/p35247514_122130_Generic.zip` |
| `PATCH_REMOTE_PATH` | Patch path on Windows server | `E:\Oracle\patches\p35247514_122130_Generic.zip` |
| `PATCH_EXTRACT_PATH` | Patch extraction path | `E:\Oracle\Middleware\patches\35247514` |
| `ORACLE_HOME` | Oracle Home path | `E:\Oracle\Middleware\Oracle_Home` |

### **4. Common Execution Control Parameters**

All pipelines include these common parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `DRY_RUN` | Run in check mode | `true` |
| `VERBOSE` | Enable verbose output | `true` |
| `HOST_BY_HOST` | Execute host by host | `true` |
| `SKIP_FIRST_CONFIRMATION` | Skip first host confirmation | `true` |
| `PAUSE_MINUTES` | Pause between hosts | `30` |

## 🚀 **Usage Examples**

### **Example 1: Java Upgrade on MedGo PROD**
```
Pipeline File: Jenkinsfile_Java_Upgrade

Environment Variables (Set in Pipeline):
PLAYBOOK_PATH: yml/medgo/prod/weblogic
YAML_FILE: upgrade_Java_weblogic.yml

Parameters:
HOST_GROUP: windows_prod_medgo
OLD_JAVA_VERSION: jdk-11.0.12
NEW_JAVA_VERSION: jdk-11.0.60
JAVA_INSTALLER: jdk-11.0.60-windows-x64.exe
JAVA_INSTALL_DIR: E:\jdk-11.0.60
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
BACKUP_DIR: E:\Oracle\backup
JAVA_SOURCE_DIR: E:\Java_source
```

### **Example 2: OPatch Upgrade on Takaful DR**
```
Pipeline File: Jenkinsfile_OPatch_Upgrade

Environment Variables (Set in Pipeline):
PLAYBOOK_PATH: yml/takaful/dr/weblogic
YAML_FILE: upgrade_opatch_windows.yml

Parameters:
HOST_GROUP: windows_dr_takaful
LOCAL_OPATCH_JAR: /home/appadmin/OPatch/6880880/opatch_generic.jar
OPATCH_TEMP_DIR: E:\OPatch_source
JAVA_PATH: E:\jdk1.8.0_441\bin\java.exe
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
```

### **Example 3: WebLogic Patch on Batch UAT**
```
Pipeline File: Jenkinsfile_WebLogic_Patch

Environment Variables (Set in Pipeline):
PLAYBOOK_PATH: yml/batch/uat/weblogic
YAML_FILE: Apply_Patch_weblogic.yml

Parameters:
HOST_GROUP: windows_uat_batch
PATCH_NUMBER: 35247514
PATCH_FILE: p35247514_122130_Generic.zip
PATCH_LOCAL_PATH: /home/appadmin/patches/p35247514_122130_Generic.zip
PATCH_REMOTE_PATH: E:\Oracle\patches\p35247514_122130_Generic.zip
PATCH_EXTRACT_PATH: E:\Oracle\Middleware\patches\35247514
ORACLE_HOME: E:\Oracle\Middleware\Oracle_Home
```

## 🔍 **Host Group Naming Convention**

All pipelines expect host groups to follow this pattern:
```
windows_{environment}_{business_line}
```

**Examples:**
- `windows_prod_medgo` - MedGo business line in PROD environment
- `windows_dr_takaful` - Takaful business line in DR environment
- `windows_uat_batch` - Batch business line in UAT environment
- `windows_sit_external_report` - External Reports business line in SIT environment

## 📁 **Playbook Path Convention**

All pipelines expect playbook paths to follow this pattern:
```
yml/{business_line}/{environment}/weblogic
```

**Examples:**
- `yml/medgo/prod/weblogic` - MedGo business line in PROD environment
- `yml/takaful/dr/weblogic` - Takaful business line in DR environment
- `yml/batch/uat/weblogic` - Batch business line in UAT environment

## ⚠️ **Important Notes**

### **1. Environment Variables Configuration**
- **`PLAYBOOK_PATH`** and **`YAML_FILE`** are set as environment variables in each pipeline
- **Modify these values** in the pipeline configuration for each business line and environment
- **No need to change parameters** - just update the environment section of the pipeline

### **2. Pipeline-Specific Validation**
Each pipeline validates that:
- **Java Upgrade**: Only accepts YAML files containing `upgrade_Java_weblogic`
- **OPatch Upgrade**: Only accepts YAML files containing `upgrade_opatch_windows`
- **WebLogic Patch**: Only accepts YAML files containing `Apply_Patch_weblogic`

### **3. Vault Password File**
- Ensure `.vault_pass` file exists in Jenkins workspace
- File should contain the vault password for your environment
- File permissions should be restricted to Jenkins user

### **4. Inventory File**
- Ensure `inventory` file is accessible to Jenkins
- Host groups must be properly defined
- All target hosts must be reachable

### **5. Playbook Files**
- Ensure playbook files exist in specified paths
- Playbooks must be compatible with target hosts
- All required variables must be configurable

### **6. Host-by-Host Execution**
- Pipeline will pause for user confirmation between hosts
- Default pause is 30 minutes (configurable)
- First host confirmation can be skipped if needed

## 🔧 **Setup Instructions**

### **1. Create Jenkins Pipelines**
1. **Copy each Jenkinsfile** to your Jenkins server
2. **Create new pipeline jobs** using each file:
   - `Jenkinsfile_Java_Upgrade` → Java Upgrade Pipeline
   - `Jenkinsfile_OPatch_Upgrade` → OPatch Upgrade Pipeline
   - `Jenkinsfile_WebLogic_Patch` → WebLogic Patch Pipeline

### **2. Configure Environment Variables**
1. **For each pipeline job**, modify the environment section:
   ```groovy
   environment {
       VAULT_PASSWORD_FILE = '.vault_pass'
       ANSIBLE_INVENTORY = 'inventory'
       PLAYBOOK_PATH = 'yml/{business_line}/{environment}/weblogic'  // Set this manually
       YAML_FILE = '{operation_file}.yml'                           // Set this manually
   }
   ```

2. **Examples for different business lines**:
   ```groovy
   // MedGo PROD
   PLAYBOOK_PATH = 'yml/medgo/prod/weblogic'
   
   // Takaful DR
   PLAYBOOK_PATH = 'yml/takaful/dr/weblogic'
   
   // Batch UAT
   PLAYBOOK_PATH = 'yml/batch/uat/weblogic'
   ```

### **3. Configure Vault Password**
1. **Create `.vault_pass` file** in Jenkins workspace
2. **Set file permissions** to Jenkins user only
3. **Add vault password** to the file

### **4. Test Each Pipeline**
1. **Start with DRY_RUN** to validate parameters
2. **Test in non-production** environment first
3. **Verify host connectivity** and playbook paths

## 📊 **Execution Flow**

All pipelines follow the same execution pattern:

1. **Parameter Validation** - Checks operation-specific parameters
2. **Host Discovery** - Retrieves host list from inventory
3. **Pre-Execution Summary** - Displays operation details
4. **Execution** - Runs operation on hosts (host-by-host or parallel)
5. **Post-Execution** - Generates completion report

## 🎯 **Best Practices**

1. **Use the correct pipeline** for each operation type
2. **Set environment variables** for each business line and environment
3. **Always test with DRY_RUN first** - Validate parameters and connectivity
4. **Use descriptive host group names** - Makes targeting easier
5. **Verify playbook paths** - Ensure files exist before execution
6. **Monitor execution logs** - Track progress and identify issues
7. **Use vault password files** - Secure credential management
8. **Test in non-production first** - Validate in safe environment

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Wrong pipeline for operation**
   - Use `Jenkinsfile_Java_Upgrade` for Java upgrades
   - Use `Jenkinsfile_OPatch_Upgrade` for OPatch upgrades
   - Use `Jenkinsfile_WebLogic_Patch` for WebLogic patches

2. **Wrong playbook path or YAML file**
   - Check environment variables in pipeline configuration
   - Verify `PLAYBOOK_PATH` matches your business line and environment
   - Verify `YAML_FILE` matches the operation type

3. **No hosts found**
   - Check host group name in inventory
   - Verify inventory file path
   - Check vault password file

4. **Playbook not found**
   - Verify `PLAYBOOK_PATH` environment variable
   - Check file permissions
   - Ensure playbook exists

5. **Vault authentication failed**
   - Check vault password file
   - Verify file permissions
   - Test vault password manually

6. **Host connection failed**
   - Check network connectivity
   - Verify host credentials
   - Check firewall settings

## 📚 **Related Documentation**

- `BUSINESS_LINE_VAULT_USAGE.md` - Business line execution guide
- `VAULT_SETUP_README.md` - Ansible Vault setup and usage
- `Jenkinsfile_Business_Line_Master` - Full business line pipeline
- `Jenkinsfile_Simplified_Master` - Simplified unified pipeline
- `config_examples/` - Configuration examples directory

---

**These separate pipelines give you focused, operation-specific Jenkins jobs with only the relevant parameters for each operation type. The `PLAYBOOK_PATH` and `YAML_FILE` are now environment variables that you can set manually in each pipeline configuration for different business lines and environments.**
