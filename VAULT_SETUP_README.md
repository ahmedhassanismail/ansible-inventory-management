# Ansible Vault Setup Guide

## Overview

This guide explains how to use Ansible Vault to securely store sensitive information like passwords, API keys, and other credentials instead of having them in plaintext files.

## What is Ansible Vault?

Ansible Vault is a feature that allows you to encrypt sensitive data in your Ansible playbooks, inventory files, and variable files. This prevents sensitive information from being exposed in plaintext.

## Current Setup

We have separated sensitive variables into encrypted vault files:

- `group_vars/windows.yml` - Non-sensitive Windows variables
- `group_vars/windows_vault.yml` - Sensitive Windows variables (to be encrypted)
- `group_vars/redhat.yml` - RedHat variables (already non-sensitive)

## Step-by-Step Setup

### 1. Encrypt the Vault File

On your Ansible control node, run:

```bash
# Encrypt the vault file (you'll be prompted for a password)
ansible-vault encrypt group_vars/windows_vault.yml

# Or specify the password directly
ansible-vault encrypt group_vars/windows_vault.yml --ask-vault-pass
```

### 2. Create a Vault Password File (Optional but Recommended)

```bash
# Create a password file
echo "your_vault_password_here" > .vault_pass

# Set restrictive permissions (Linux/Mac)
chmod 600 .vault_pass

# On Windows, ensure only authorized users can access the file
```

### 3. Test the Setup

```bash
# Test with password prompt
ansible-playbook --ask-vault-pass -i inventory test-playbook.yml

# Test with password file
ansible-playbook --vault-password-file .vault_pass -i inventory test-playbook.yml
```

## Usage Examples

### Running Playbooks with Vault

```bash
# Method 1: Password prompt (interactive)
ansible-playbook --ask-vault-pass -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"

# Method 2: Password file (automated)
ansible-playbook --vault-password-file .vault_pass -i inventory yml/prod/weblogic/upgrade_Java_weblogic.yml \
  -e "old_java_version='jdk-11.0.12'" \
  -e "new_java_version='jdk-11.0.60'" \
  -e "java_installer='jdk-11.0.60-windows-x64.exe'" \
  -e "java_install_dir='E:\\jdk-11.0.60'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "backup_dir='E:\\Oracle\\backup'" \
  -e "java_source_dir='E:\\Java_source'"
```

### Jenkins Pipeline Integration

Update your Jenkins pipelines to include vault password:

```groovy
pipeline {
    agent any
    
    environment {
        VAULT_PASSWORD_FILE = '.vault_pass'
    }
    
    stages {
        stage('Execute WebLogic Upgrade') {
            steps {
                sh """
                    ansible-playbook --vault-password-file ${VAULT_PASSWORD_FILE} -i inventory upgrade_Java_weblogic.yml \\
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

## Vault Management Commands

### Viewing Encrypted Files

```bash
# View encrypted file content
ansible-vault view group_vars/windows_vault.yml

# List encrypted files
find . -name "*.yml" -exec ansible-vault view {} \; 2>/dev/null | grep -l "Vault" || echo "No encrypted files found"
```

### Editing Encrypted Files

```bash
# Edit encrypted file
ansible-vault edit group_vars/windows_vault.yml

# Rekey (change password)
ansible-vault rekey group_vars/windows_vault.yml
```

### Decrypting Files (Temporary)

```bash
# Decrypt for editing (remember to re-encrypt!)
ansible-vault decrypt group_vars/windows_vault.yml

# After editing, re-encrypt
ansible-vault encrypt group_vars/windows_vault.yml
```

## Security Best Practices

### 1. Password Management

- Use strong, unique passwords for vault files
- Store vault passwords securely (password managers, secure key stores)
- Never commit vault passwords to version control

### 2. File Permissions

```bash
# Linux/Mac: Restrict access to vault password file
chmod 600 .vault_pass

# Windows: Ensure only authorized users can access
# Right-click → Properties → Security → Edit permissions
```

### 3. CI/CD Integration

- Store vault passwords as Jenkins credentials
- Use environment variables for vault passwords in pipelines
- Never hardcode vault passwords in scripts

### 4. Backup and Recovery

- Keep secure backups of vault passwords
- Document recovery procedures
- Test vault decryption regularly

## Troubleshooting

### Common Issues

1. **"Vault password is required"**
   - Ensure you're using `--ask-vault-pass` or `--vault-password-file`
   - Check that the vault file is properly encrypted

2. **"Decryption failed"**
   - Verify the vault password is correct
   - Check if the file was corrupted during transfer

3. **"Permission denied"**
   - Ensure vault password file has correct permissions
   - Check file ownership

### Debug Commands

```bash
# Check if file is encrypted
ansible-vault view group_vars/windows_vault.yml

# Verify vault file integrity
ansible-vault view group_vars/windows_vault.yml > /dev/null && echo "Vault file is valid" || echo "Vault file is corrupted"

# Test playbook syntax with vault
ansible-playbook --vault-password-file .vault_pass -i inventory --syntax-check playbook.yml
```

## Migration from Plaintext

If you're migrating from plaintext passwords:

1. **Backup current files**
2. **Create vault file with sensitive data**
3. **Encrypt vault file**
4. **Update main variable files to remove sensitive data**
5. **Test with vault password**
6. **Remove plaintext files**

## Benefits of This Approach

✅ **Security**: Passwords are encrypted at rest  
✅ **Compliance**: Meets security audit requirements  
✅ **Collaboration**: Team members can work without seeing credentials  
✅ **CI/CD**: Automated deployments with secure credential handling  
✅ **Audit Trail**: Clear separation of sensitive vs. non-sensitive data  

## Next Steps

1. Encrypt `group_vars/windows_vault.yml` on your Ansible control node
2. Test the setup with a simple playbook
3. Update your Jenkins pipelines to use vault passwords
4. Consider encrypting other sensitive variables if needed
5. Document your vault password management procedures

---

**Remember**: Always keep your vault passwords secure and never commit them to version control!
