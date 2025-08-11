# WebLogic Configuration Examples - Using Configurable Variables

## Overview

The updated WebLogic upgrade playbook now supports configurable regexp patterns and replacement values through variables. This makes it easy to customize the behavior for different environments, WebLogic versions, or specific requirements.

## Basic Usage

### **1. Using Default Values**
```bash
# Run with default regexp patterns
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml
```

### **2. Override Specific Variables**
```bash
# Override specific regexp patterns
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "java_home_regexp='^JAVA_HOME=.*'" \
  -e "nodemanager_java_home_regexp='^JavaHome=.*'"
```

### **3. Using Configuration File**
```bash
# Use a custom configuration file
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e @weblogic_config_vars.yml
```

## Configuration File Examples

### **Basic Configuration Override**
```yaml
# weblogic_config_vars.yml
---
# Custom regexp patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*"
weblogic_home_regexp: "^#.*WebLogic.*Home.*|^WL_HOME=.*"

# Custom paths
java_install_dir: "E:\\jdk-11.0.12"
oracle_home: "E:\\Oracle\\Middleware\\Oracle_Home_14c"
```

### **Environment-Specific Configuration**
```yaml
# prod_config.yml
---
# Production environment settings
backup_dir: "E:\\Oracle\\backup"
weblogic_domain: "prod_domain"
java_install_dir: "E:\\jdk1.8.0_441"

# Production-specific regexp patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^ORACLE_HOME=.*"
```

```yaml
# dr_config.yml
---
# DR environment settings
backup_dir: "F:\\Oracle\\backup"
weblogic_domain: "dr_domain"
java_install_dir: "F:\\jdk1.8.0_441"

# DR-specific regexp patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^DR_JAVA_HOME=.*"
```

### **WebLogic Version-Specific Patterns**
```yaml
# weblogic_12c_config.yml
---
# WebLogic 12c specific patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^ORACLE_HOME=.*"
weblogic_home_regexp: "^#.*WebLogic.*Home.*|^WL_HOME=.*|^MW_HOME=.*"
```

```yaml
# weblogic_14c_config.yml
---
# WebLogic 14c specific patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^GRAALVM_HOME=.*"
weblogic_home_regexp: "^#.*WebLogic.*Home.*|^WL_HOME=.*|^ORACLE_HOME=.*"
```

## Jenkins Pipeline Usage

### **1. Basic Pipeline Execution**
```groovy
// Jenkins will use default values
pipeline {
    agent any
    parameters {
        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['PROD', 'DR', 'TEST', 'DEV', 'UAT', 'SIT']
        )
    }
    // ... rest of pipeline
}
```

### **2. With Custom Configuration File**
```groovy
// Jenkins will use custom configuration file
pipeline {
    agent any
    parameters {
        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['PROD', 'DR', 'TEST', 'DEV', 'UAT', 'SIT']
        )
        string(
            name: 'CUSTOM_CONFIG_FILE',
            defaultValue: 'yml/prod/weblogic/weblogic_config_vars.yml'
        )
    }
    // ... rest of pipeline
}
```

### **3. With Extra Variables**
```groovy
// Jenkins will pass extra variables
pipeline {
    agent any
    parameters {
        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['PROD', 'DR', 'TEST', 'DEV', 'UAT', 'SIT']
        )
        string(
            name: 'ANSIBLE_EXTRA_VARS',
            defaultValue: 'java_home_regexp="^JAVA_HOME=.*" java_install_dir="E:\\jdk-11.0.12"'
        )
    }
    // ... rest of pipeline
}
```

## Advanced Configuration Examples

### **1. Multiple Pattern Matching**
```yaml
# Support multiple pattern formats
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^ORACLE_HOME=.*|^JAVA_HOME_PATH=.*"
```

### **2. Environment-Specific Domains**
```yaml
# Different domains for different environments
weblogic_domain: "{{ weblogic_domain | default('base_domain') }}"

# Override per environment
# PROD: base_domain
# DR: dr_domain  
# TEST: test_domain
# DEV: dev_domain
```

### **3. Custom Backup Strategies**
```yaml
# Environment-specific backup directories
backup_dir: "{{ backup_dir | default('E:\\Oracle\\backup') }}"

# Override examples:
# PROD: E:\Oracle\backup
# DR: F:\Oracle\backup
# TEST: D:\Oracle\backup
```

## Variable Precedence

The variables follow this precedence order (highest to lowest):

1. **Command Line Variables** (`-e` parameters)
2. **Configuration File** (`-e @file.yml`)
3. **Jenkins Parameters** (ANSIBLE_EXTRA_VARS)
4. **Playbook Defaults** (defined in vars section)

### **Example Precedence**
```bash
# 1. Command line (highest priority)
ansible-playbook playbook.yml -e "java_home_regexp='^CUSTOM=.*'"

# 2. Configuration file
ansible-playbook playbook.yml -e @config.yml

# 3. Jenkins parameters
# Set in Jenkins pipeline

# 4. Playbook defaults (lowest priority)
# Defined in the playbook vars section
```

## Troubleshooting

### **1. Check Variable Values**
```bash
# Run with verbose output to see variable values
ansible-playbook -i inventory upgrade_Java_weblogic.yml -vvv
```

### **2. Validate Configuration File**
```bash
# Check if configuration file is valid YAML
ansible-playbook -i inventory upgrade_Java_weblogic.yml -e @config.yml --check
```

### **3. Test Specific Variables**
```bash
# Test specific variable overrides
ansible-playbook -i inventory upgrade_Java_weblogic.yml \
  -e "java_home_regexp='^TEST=.*'" \
  --check
```

## Best Practices

### **1. Configuration Management**
- Keep environment-specific configs in separate files
- Use descriptive names for configuration files
- Version control all configuration files

### **2. Testing**
- Always test regexp patterns in lower environments
- Use `--check` mode to preview changes
- Validate patterns against actual file content

### **3. Documentation**
- Document custom regexp patterns
- Maintain examples for each environment
- Keep configuration files well-commented

### **4. Security**
- Avoid hardcoding sensitive values
- Use Jenkins credentials for sensitive data
- Validate all input parameters

## Complete Example Workflow

### **1. Create Environment Configuration**
```yaml
# yml/prod/weblogic/prod_config.yml
---
# Production environment configuration
backup_dir: "E:\\Oracle\\backup"
weblogic_domain: "prod_domain"
java_install_dir: "E:\\jdk1.8.0_441"

# Production-specific regexp patterns
java_home_regexp: "^#.*Java.*Home.*|^JAVA_HOME=.*|^ORACLE_HOME=.*"
weblogic_home_regexp: "^#.*WebLogic.*Home.*|^WL_HOME=.*|^MW_HOME=.*"
nodemanager_java_home_regexp: "^JavaHome=.*|^#.*JavaHome.*"
```

### **2. Run with Configuration**
```bash
# Execute with production configuration
ansible-playbook -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e @yml/prod/weblogic/prod_config.yml
```

### **3. Jenkins Pipeline**
```groovy
// Jenkins pipeline with production config
pipeline {
    agent any
    parameters {
        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['PROD', 'DR', 'TEST', 'DEV', 'UAT', 'SIT']
        )
        string(
            name: 'CUSTOM_CONFIG_FILE',
            defaultValue: 'yml/prod/weblogic/prod_config.yml'
        )
    }
    // ... rest of pipeline
}
```

This approach provides maximum flexibility while maintaining consistency across environments and making the playbook easily maintainable and customizable.
