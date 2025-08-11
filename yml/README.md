# YAML Configuration Directory Structure

This directory contains application-specific configurations organized by business line and environment type.

## Directory Structure

```
yml/
├── prod/                    # Production Environment
│   ├── weblogic/           # WebLogic Applications
│   │   ├── medgo.yml       # MedGo Application
│   │   ├── batch.yml       # Batch Processing
│   │   ├── external_reports.yml
│   │   ├── ncci.yml        # NCCI Application
│   │   └── wasel.yml       # Wasel Application
│   ├── tomcat/             # Tomcat Applications
│   │   ├── docmosis.yml    # Docmosis Application
│   │   ├── digital.yml     # Digital Application
│   │   ├── filenet.yml     # FileNet Application
│   │   └── marine.yml      # Marine Application
│   ├── jboss/              # JBoss Applications
│   │   └── ebusiness.yml   # eBusiness Application
│   └── httpd/              # HTTPD Applications
│       ├── teammate.yml    # Teammate Application
│       └── digital.yml     # Digital Application
├── dr/                     # Disaster Recovery Environment
│   ├── weblogic/
│   ├── tomcat/
│   ├── jboss/
│   └── httpd/
├── test/                   # Test Environment
│   ├── weblogic/
│   ├── tomcat/
│   ├── jboss/
│   └── httpd/
├── dev/                    # Development Environment
│   ├── weblogic/
│   │   └── takaful.yml     # Takaful Application
│   ├── tomcat/
│   ├── jboss/
│   └── httpd/
├── uat/                    # User Acceptance Testing Environment
│   ├── weblogic/
│   ├── tomcat/
│   ├── jboss/
│   └── httpd/
└── sit/                    # System Integration Testing Environment
    ├── weblogic/
    ├── tomcat/
    ├── jboss/
    └── httpd/
```

## Purpose

This structure allows for:
- **Environment-specific configurations**: Different settings for Prod, DR, Test, Dev, UAT, and SIT
- **Middleware-specific configurations**: WebLogic, Tomcat, JBoss, and HTTPD specific settings
- **Application-specific configurations**: Custom variables for each business application
- **Centralized configuration management**: Easy to maintain and version control
- **Environment promotion**: Simple to promote configurations from Dev → Test → UAT → Prod

## Usage

### In Ansible Playbooks

```yaml
---
- name: Deploy MedGo Application
  hosts: prod_weblogic_medgo
  vars_files:
    - "{{ playbook_dir }}/yml/prod/weblogic/medgo.yml"
  tasks:
    - name: Configure WebLogic
      # Use variables from medgo.yml
      debug:
        msg: "Deploying {{ application_name }} on port {{ app_port }}"
```

### In Inventory

```ini
[prod_weblogic_medgo:vars]
vars_files:
  - yml/prod/weblogic/medgo.yml
```

## Configuration Categories

Each YAML file typically contains:

1. **Application Identity**: Name, environment, middleware type, business line
2. **Server Configuration**: Ports, memory settings, thread pools
3. **Database Settings**: Connection pools, connection limits
4. **Environment-specific Settings**: Debug flags, monitoring, logging levels
5. **Integration Settings**: API keys, external service configurations
6. **Security Settings**: Authentication, authorization settings

## Best Practices

- Use descriptive file names that match your inventory groups
- Keep sensitive information in Ansible Vault
- Use consistent variable naming conventions
- Document all configuration options
- Version control all configuration files
- Test configurations in lower environments before promoting to production
