# Ansible Inventory Structure

This directory contains the Ansible inventory and variable files organized for better maintainability and security.

## File Structure

```
.
├── inventory                 # Main inventory file
├── group_vars/              # Group-specific variables
│   ├── windows.yml         # Windows server variables
│   ├── redhat.yml          # RedHat server variables
│   └── takaful.yml         # Takaful application variables
├── ansible.cfg              # Ansible configuration
└── README.md               # This file
```

## Variable Organization

### Windows Servers (`group_vars/windows.yml`)
All Windows servers inherit these variables:
- `ansible_connection: winrm`
- `ansible_user: tawn.com\ansadmin`
- `ansible_password: "iW=*X8{mI1~R^5tB"`
- `ansible_port: 5986`
- `ansible_winrm_transport: ntlm`
- `ansible_winrm_server_cert_validation: ignore`

### RedHat Servers (`group_vars/redhat.yml`)
All RedHat servers inherit these variables:
- `ansible_user: ansible`
- `ansible_become: yes`
- `ansible_become_method: sudo`
- `ansible_ssh_private_key_file: ~/.ssh/id_rsa`
- `ansible_python_interpreter: /usr/bin/python3`

### Takaful Application (`group_vars/takaful.yml`)
RedHat servers running Takaful application override with:
- `ansible_user: appadm`
- `ansible_ssh_private_key_file: ~/.ssh/id_rsa`
- `ansible_python_interpreter: /usr/bin/python3`

## Group Hierarchy

### Environment Groups
- `[prod]` - Production servers
- `[dr]` - Disaster Recovery servers
- `[test]` - Test servers
- `[dev]` - Development servers
- `[uat]` - User Acceptance Testing servers

### Operating System Groups
- `[redhat]` - All RedHat/Linux servers
- `[windows]` - All Windows servers

### Middleware Groups
- `[weblogic]` - WebLogic application servers
- `[tomcat]` - Tomcat application servers
- `[jboss]` - JBoss application servers
- `[httpd]` - HTTPD/Apache servers

### Application Groups
- `[medgo]` - MedGo application servers
- `[external_report]` - External Report application servers
- `[batch]` - Batch processing servers
- `[ncci]` - NCCI application servers
- `[wasel]` - Wasel application servers
- `[takaful]` - Takaful application servers
- `[docmosis]` - Docmosis application servers
- `[digital_tomcat]` - Digital Tomcat servers
- `[filenet]` - FileNet application servers
- `[marine]` - Marine application servers
- `[ebusiness]` - eBusiness application servers
- `[teammate]` - Teammate application servers
- `[digital_httpd]` - Digital HTTPD servers

## Usage

### Running Playbooks
```bash
# Target all Windows servers
ansible-playbook -i inventory playbook.yml --limit windows

# Target all RedHat servers
ansible-playbook -i inventory playbook.yml --limit redhat

# Target specific environment
ansible-playbook -i inventory playbook.yml --limit prod

# Target specific application
ansible-playbook -i inventory playbook.yml --limit medgo
```

### Variable Precedence
1. Host-specific variables (highest priority)
2. Group-specific variables (`group_vars/`)
3. All group variables (lowest priority)

## Security Notes

- **Windows credentials** are stored in `group_vars/windows.yml`
- **SSH private keys** are referenced in variable files
- **Passwords** should be encrypted using Ansible Vault in production
- **Access control** should be implemented for the `group_vars/` directory

## Best Practices

1. **Never commit sensitive data** to version control
2. **Use Ansible Vault** for encrypting sensitive variables
3. **Keep variable files organized** by group and purpose
4. **Document any custom variables** or overrides
5. **Test variable inheritance** before deploying to production
