# WebLogic Upgrade Playbook - Java Version Replacement

## Overview

This playbook is designed to update Java versions in WebLogic configuration files. **The executor MUST provide the old and new Java versions via command line variables.**

## What It Does

The playbook will:
1. **Validate** that required Java version variables are provided
2. **Backup** all WebLogic configuration files with timestamps
3. **Search** for the old Java version in each file
4. **Replace** it with the new Java version
5. **Verify** the changes were made successfully

## ⚠️ **REQUIRED VARIABLES**

**The executor MUST provide these variables when running the playbook:**

- `old_java_version` - The Java version to search for and replace in WebLogic files
- `new_java_version` - The new Java version to replace with in WebLogic files
- `java_installer` - The Java installer filename (must exist in ansible_source_dir)
- `java_install_dir` - The Java installation directory on the Windows server
- `oracle_home` - The Oracle Home directory path on the Windows server
- `backup_dir` - The backup directory path for WebLogic files
- `java_source_dir` - The Java source directory on the Windows server

**Optional variables (have defaults):**
- `weblogic_domain` - WebLogic domain name (defaults to 'base_domain')
- `ansible_source_dir` - Source directory on Ansible server (defaults to '/home/appadmin/Upgrade_weblogic_files')

## Files That Will Be Updated

- `.globalEnv.properties` - Oracle Global Environment Properties
- `nodemanager.properties` - Node Manager Properties  
- `setNMJavaHome.cmd` - Node Manager Java Home Script
- `setDomainEnv.cmd` - Domain Environment Script

## Usage Examples

### **1. Command Line Variables (REQUIRED)**
```bash
# Replace jdk-11.0.12 with jdk-11.0.60
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

### **2. Configuration File**
```bash
# Use the java_version_update.yml file
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e @java_version_update.yml
```

### **3. Different Version Examples**
```bash
# Update from JDK 8 to JDK 11
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-8.0.441'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"

# Update to newer JDK 11 version
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.75'" \
  -e "java_installer='jdk-11.0.75-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.75'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"

# Update from JDK 11 to JDK 17
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.60'" \
  -e "new_java_version='jdk-17.0.9'" \
  -e "java_installer='jdk-17.0.9-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-17.0.9'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

## Configuration File Example

```yaml
# java_version_update.yml
---
# REQUIRED: Old Java version to search for and replace in WebLogic files
old_java_version: "jdk-11.0.12"

# REQUIRED: New Java version to replace with in WebLogic files
new_java_version: "jdk-11.0.60"

# REQUIRED: Java installer filename (must exist in ansible_source_dir)
java_installer: "jdk-11.0.60-windows-x64.exe"

# REQUIRED: Java installation directory on Windows server
java_install_dir: "E:\\jdk-11.0.60"

# REQUIRED: Oracle Home directory path
oracle_home: "E:\\Oracle\\Middleware\\Oracle_Home"

# REQUIRED: Backup directory path for WebLogic files
backup_dir: "E:\\Oracle\\backup"

# REQUIRED: Java source directory on Windows server
java_source_dir: "E:\\Java_source"

# OPTIONAL: WebLogic domain name (defaults to 'base_domain')
weblogic_domain: "base_domain"

# OPTIONAL: Source directory on Ansible server (defaults to '/home/appadmin/Upgrade_weblogic_files')
ansible_source_dir: "/home/appadmin/Upgrade_weblogic_files"
```

## How It Works

1. **Validation**: Checks that required variables are provided
2. **Backup**: Creates timestamped backups of all files
3. **Search**: Looks for the old Java version string in each file
4. **Replace**: Updates the old version with the new version
5. **Verify**: Confirms the changes were applied

## File Structure

```
yml/prod/weblogic/
├── upgrade_Java_weblogic.yml      # Main playbook
├── java_version_update.yml         # Java version configuration
├── rollback_weblogic.yml          # Rollback playbook
└── README.md                      # This file
```

## Troubleshooting

### **Missing Variables Error**
If you see this error:
```
Required variables must be provided via command line:
- old_java_version: NOT PROVIDED
- new_java_version: NOT PROVIDED
- java_installer: NOT PROVIDED
- java_install_dir: NOT PROVIDED
- oracle_home: NOT PROVIDED
- backup_dir: NOT PROVIDED
- java_source_dir: NOT PROVIDED
```

**Solution**: Provide ALL seven required variables as shown in the usage examples above.

### **Check What Will Be Replaced**
```bash
# Run with verbose output to see what's being searched
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'" \
  -vvv
```

### **Test the Replacement**
```bash
# Test without making changes
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'" \
  --check
```

### **Common Issues**
1. **Variables Not Provided**: Always include `-e` parameters for ALL seven required variables
2. **Version Not Found**: Check if the old version exists in your files
3. **Wrong Replacement**: Verify the new version string is correct
4. **File Not Found**: Ensure WebLogic files exist in expected locations
5. **Installer Missing**: Ensure the java_installer file exists in ansible_source_dir
6. **Invalid Path**: Verify the java_install_dir path is valid for Windows
7. **Oracle Paths**: Ensure oracle_home, backup_dir, and java_source_dir paths are correct
8. **Path Format**: Use Windows path format with double backslashes (E:\\path\\to\\dir)

## Best Practices

1. **Always Provide Variables**: Never run without specifying Java versions
2. **Test First**: Use `--check` mode to preview changes
3. **Verify Changes**: Check that the correct versions were updated
4. **Backup Ready**: The playbook automatically creates backups
5. **Rollback Ready**: Use the rollback playbook if needed

## Example Output

When you run the playbook, you'll see:
```
=== WebLogic Upgrade Started ===
Target Host: your-server
Environment: PROD
Java Version Update: jdk-11.0.12 → jdk-11.0.60
Timestamp: 2024-01-15T10:30:00Z

=== WebLogic Configuration Updates ===
File: E:\Oracle\Middleware\Oracle_Home\oui\.globalEnv.properties
Search Pattern: jdk-11.0.12
Replace With: jdk-11.0.60
Description: Update Java version from jdk-11.0.12 to jdk-11.0.60
```

**Remember: The executor MUST provide the Java version variables for the playbook to work!** 🎯
