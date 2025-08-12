# OPatch Upgrade Playbook

## Overview
This playbook upgrades OPatch on WebLogic Windows servers using the `opatch_generic.jar` file. **ALL variables must be provided via command line.**

## Required Variables
- `local_opatch_jar` - Path to OPatch JAR file on Ansible server
- `opatch_temp_dir` - Temporary directory on Windows server for OPatch JAR
- `java_path` - Java executable path on Windows server
- `oracle_home` - Oracle Home directory path on Windows server

## What It Does
1. Creates temporary directory on Windows server
2. Copies OPatch JAR from Ansible server to Windows
3. Runs OPatch upgrade using Java
4. Verifies new OPatch version
5. Provides detailed output and summary

## Usage Examples

### Command Line
```bash
ansible-playbook -i inventory upgrade_opatch_windows.yml \
  -e "local_opatch_jar='/home/appadmin/OPatch/6880880/opatch_generic.jar'" \
  -e "opatch_temp_dir='E:\\OPatch_source'" \
  -e "java_path='E:\\jdk1.8.0_441\\bin\\java.exe'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'"
```

### Configuration File
```bash
ansible-playbook -i inventory upgrade_opatch_windows.yml -e @opatch_upgrade_config.yml
```

## Troubleshooting
- **Missing Variables**: Provide all 4 required variables
- **File Not Found**: Check OPatch JAR exists in source path
- **Permission Issues**: Verify file permissions
- **Path Format**: Use Windows format (E:\\path\\to\\dir)
- **Java Issues**: Ensure Java path is correct and executable

## Success Indicators
- ✅ All stages completed without errors
- 📦 OPatch JAR copied successfully
- 🔧 OPatch upgrade completed
- 📊 Version verification successful
- 📋 Detailed execution summary provided

**Remember**: Always test with `--check` mode first! 🚀
