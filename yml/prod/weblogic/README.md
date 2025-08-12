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

- `old_java_version` - The Java version to search for and replace
- `new_java_version` - The new Java version to replace with

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
  -e "new_java_version='jdk-11.0.60'"
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
  -e "new_java_version='jdk-11.0.60'"

# Update to newer JDK 11 version
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.75'"

# Update from JDK 11 to JDK 17
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.60'" \
  -e "new_java_version='jdk-17.0.9'"
```

## Configuration File Example

```yaml
# java_version_update.yml
---
# REQUIRED: Old Java version to search for
old_java_version: "jdk-11.0.12"

# REQUIRED: New Java version to replace with
new_java_version: "jdk-11.0.60"
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
```

**Solution**: Provide the variables as shown in the usage examples above.

### **Check What Will Be Replaced**
```bash
# Run with verbose output to see what's being searched
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -vvv
```

### **Test the Replacement**
```bash
# Test without making changes
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  --check
```

### **Common Issues**
1. **Variables Not Provided**: Always include `-e` parameters for Java versions
2. **Version Not Found**: Check if the old version exists in your files
3. **Wrong Replacement**: Verify the new version string is correct
4. **File Not Found**: Ensure WebLogic files exist in expected locations

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
