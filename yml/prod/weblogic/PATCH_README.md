# WebLogic Patch Application Playbook

## Overview
This playbook applies WebLogic patches using OPatch on Windows servers. **ALL variables must be provided via command line.**

## Required Variables
- `patch_number` - Patch ID (e.g., "35247514")
- `patch_file` - Patch ZIP filename
- `oracle_home` - Oracle Home path on Windows
- `patch_local_path` - Source path on Ansible server
- `patch_remote_path` - Destination path on Windows
- `patch_extract_path` - Extraction directory on Windows

## Usage Examples

### Command Line
```bash
ansible-playbook -i inventory Apply_Patch_weblogic.yml \
  -e "patch_number='35247514'" \
  -e "patch_file='p35247514_122130_Generic.zip'" \
  -e "oracle_home='E:\\Oracle\\Middleware\\Oracle_Home'" \
  -e "patch_local_path='/home/appadmin/patches/p35247514_122130_Generic.zip'" \
  -e "patch_remote_path='E:\\Oracle\\patches\\p35247514_122130_Generic.zip'" \
  -e "patch_extract_path='E:\\Oracle\\Middleware\\patches\\35247514'"
```

### Configuration File
```bash
ansible-playbook -i inventory Apply_Patch_weblogic.yml -e @patch_config.yml
```

## What It Does
1. Creates patch directories
2. Copies patch ZIP to Windows server
3. Extracts patch files
4. Applies patch using OPatch
5. Provides detailed output and summary

## Troubleshooting
- **Missing Variables**: Provide all 6 required variables
- **File Not Found**: Check patch file exists in source path
- **Permission Issues**: Verify file permissions
- **Path Format**: Use Windows format (E:\\path\\to\\dir)

## Success Indicators
- ✅ All stages completed without errors
- 📊 Patch files extracted successfully
- 🔧 OPatch applied patch without errors
- 📋 Detailed execution summary provided

**Remember**: Always test with `--check` mode first! 🚀
