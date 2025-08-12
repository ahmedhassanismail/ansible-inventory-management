# WebLogic Upgrade Playbook - Search Pattern Variables

## Overview

This playbook uses configurable search patterns to find and replace text in WebLogic configuration files. The search patterns are defined as variables at the beginning of the playbook and can be easily customized.

## Key Variables

### **File Replacement Variables**
The `file_replacements` list defines what to search for and replace in each file:

```yaml
file_replacements:
  - file: "path/to/file"
    search_pattern: "text to search for"
    replace_with: "text to replace with"
    description: "what this replacement does"
```

### **Search Pattern Variables**
These variables define the exact text to search for in each file:

- `search_java_home`: Text to find for Java home (default: "JAVA_HOME=")
- `search_weblogic_home`: Text to find for WebLogic home (default: "WL_HOME=")
- `search_nodemanager_java`: Text to find for Node Manager Java (default: "JavaHome=")
- `search_setnm_java`: Text to find in setNMJavaHome.cmd (default: "set JAVA_HOME=")
- `search_domain_java`: Text to find in setDomainEnv.cmd (default: "set JAVA_HOME=")
- `search_domain_path`: Text to find for PATH in setDomainEnv.cmd (default: "set PATH=")

## Usage Examples

### **1. Use Default Search Patterns**
```bash
# Run with default patterns
ansible-playbook -i inventory upgrade_Java_weblogic.yml
```

### **2. Override Specific Search Patterns**
```bash
# Override specific patterns
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "search_java_home='ORACLE_JAVA_HOME='" \
  -e "search_weblogic_home='WEBLOGIC_HOME='"
```

### **3. Use Custom Configuration File**
```bash
# Use a custom configuration file
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e @custom_search_patterns.yml
```

## Customizing Search Patterns

### **Example 1: Different Variable Names**
If your files use different variable names:

```yaml
# custom_patterns.yml
search_java_home: "ORACLE_JAVA_HOME="
search_weblogic_home: "WEBLOGIC_HOME="
search_nodemanager_java: "NODEMANAGER_JAVA="
```

### **Example 2: Different File Formats**
If your files have different formats:

```yaml
# custom_patterns.yml
search_java_home: "JAVA_HOME:"
search_weblogic_home: "WL_HOME:"
search_nodemanager_java: "JavaHome:"
```

### **Example 3: Environment-Specific Patterns**
For different environments:

```yaml
# prod_patterns.yml
search_java_home: "PROD_JAVA_HOME="
search_weblogic_home: "PROD_WL_HOME="

# dr_patterns.yml
search_java_home: "DR_JAVA_HOME="
search_weblogic_home: "DR_WL_HOME="
```

## How It Works

1. **Backup**: Original files are backed up with timestamps
2. **Search**: The playbook searches for the specified text patterns in each file
3. **Replace**: When found, the text is replaced with the new values
4. **Verify**: File content is verified after replacement

## File Structure

```
yml/prod/weblogic/
├── upgrade_Java_weblogic.yml      # Main playbook
├── custom_search_patterns.yml     # Example custom patterns
├── rollback_weblogic.yml          # Rollback playbook
└── README.md                      # This file
```

## Troubleshooting

### **Check What Will Be Replaced**
```bash
# Run with verbose output to see what's being searched
ansible-playbook -i inventory upgrade_Java_weblogic.yml -vvv
```

### **Test Search Patterns**
```bash
# Test specific patterns
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "search_java_home='TEST_PATTERN='" \
  --check
```

### **Common Issues**
1. **Pattern Not Found**: Check if the search text matches exactly what's in your files
2. **Wrong Replacement**: Verify the `replace_with` values are correct
3. **File Not Found**: Ensure the file paths in `file_replacements` are correct

## Best Practices

1. **Always Backup**: The playbook automatically creates backups before making changes
2. **Test First**: Use `--check` mode to preview changes
3. **Customize Patterns**: Create environment-specific pattern files
4. **Version Control**: Keep your custom pattern files in version control
5. **Document Changes**: Update patterns when WebLogic configurations change
