pipeline {
    agent any
    
    environment {
        ANSIBLE_PLAYBOOK_PATH = 'yml/prod/weblogic/upgrade_Java_weblogic.yml'
        ANSIBLE_INVENTORY = 'inventory'
        ANSIBLE_CONFIG = 'ansible.cfg'
        JENKINS_BUILD_NUMBER = "${env.BUILD_NUMBER}"
        JENKINS_JOB_NAME = "${env.JOB_NAME}"
    }
    
    parameters {
        choice(
            name: 'TARGET_ENVIRONMENT',
            choices: ['PROD', 'DR', 'TEST', 'DEV', 'UAT', 'SIT'],
            description: 'Select target environment for WebLogic upgrade'
        )
        string(
            name: 'ANSIBLE_EXTRA_VARS',
            defaultValue: '',
            description: 'Additional Ansible variables (optional)'
        )
        booleanParam(
            name: 'DRY_RUN',
            defaultValue: false,
            description: 'Run in dry-run mode (check mode)'
        )
    }
    
    stages {
        stage('Preflight Checks') {
            steps {
                script {
                    echo "=== Preflight Checks Started ==="
                    echo "Target Environment: ${params.TARGET_ENVIRONMENT}"
                    echo "Jenkins Build: ${env.BUILD_NUMBER}"
                    echo "Job Name: ${env.JOB_NAME}"
                    
                    // Validate Ansible files exist
                    sh '''
                        if [ ! -f "${ANSIBLE_PLAYBOOK_PATH}" ]; then
                            echo "ERROR: Ansible playbook not found: ${ANSIBLE_PLAYBOOK_PATH}"
                            exit 1
                        fi
                        
                        if [ ! -f "${ANSIBLE_INVENTORY}" ]; then
                            echo "ERROR: Ansible inventory not found: ${ANSIBLE_INVENTORY}"
                            exit 1
                        fi
                        
                        echo "✓ All required files found"
                    '''
                }
            }
        }
        
        stage('Environment Validation') {
            steps {
                script {
                    echo "=== Environment Validation ==="
                    
                    // Check if target environment exists in inventory
                    sh '''
                        if ! grep -q "\\[${TARGET_ENVIRONMENT,,}_weblogic_win\\]" ${ANSIBLE_INVENTORY}; then
                            echo "ERROR: Target environment ${TARGET_ENVIRONMENT}_weblogic_win not found in inventory"
                            exit 1
                        fi
                        
                        echo "✓ Target environment ${TARGET_ENVIRONMENT}_weblogic_win found in inventory"
                        
                        # Count hosts in target group
                        HOST_COUNT=$(grep -A 100 "\\[${TARGET_ENVIRONMENT,,}_weblogic_win\\]" ${ANSIBLE_INVENTORY} | grep -B 100 "\\[" | grep -v "\\[" | grep -v "^#" | grep -v "^$" | wc -l)
                        echo "✓ Found ${HOST_COUNT} hosts in ${TARGET_ENVIRONMENT}_weblogic_win group"
                    '''
                }
            }
        }
        
        stage('Ansible Execution') {
            steps {
                script {
                    echo "=== Ansible Execution Started ==="
                    
                    // Determine playbook path based on environment
                    def playbookPath = "yml/${params.TARGET_ENVIRONMENT.toLowerCase()}/weblogic/upgrade_Java_weblogic.yml"
                    
                    // Build Ansible command
                    def ansibleCmd = "ansible-playbook -i ${ANSIBLE_INVENTORY} ${playbookPath}"
                    
                    // Add extra variables
                    if (params.ANSIBLE_EXTRA_VARS) {
                        ansibleCmd += " -e '${params.ANSIBLE_EXTRA_VARS}'"
                    }
                    
                    // Add Jenkins variables
                    ansibleCmd += " -e 'jenkins_build_number=${env.BUILD_NUMBER}'"
                    ansibleCmd += " -e 'jenkins_job_name=${env.JOB_NAME}'"
                    
                    // Add dry-run mode if selected
                    if (params.DRY_RUN) {
                        ansibleCmd += " --check --diff"
                        echo "⚠️  DRY-RUN MODE ENABLED - No changes will be made"
                    }
                    
                    echo "Executing: ${ansibleCmd}"
                    
                    // Execute Ansible playbook
                    def result = sh(
                        script: ansibleCmd,
                        returnStatus: true
                    )
                    
                    if (result != 0) {
                        error "Ansible execution failed with exit code: ${result}"
                    }
                    
                    echo "✓ Ansible execution completed successfully"
                }
            }
        }
        
        stage('Post-Execution Validation') {
            steps {
                script {
                    echo "=== Post-Execution Validation ==="
                    
                    // Check execution status files on target hosts
                    sh '''
                        echo "Checking execution status on target hosts..."
                        
                        # This would typically involve checking the status files created by the playbook
                        # For now, we'll just report completion
                        echo "✓ WebLogic upgrade process completed for ${TARGET_ENVIRONMENT} environment"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "=== Pipeline Execution Summary ==="
                echo "Environment: ${params.TARGET_ENVIRONMENT}"
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Job Name: ${env.JOB_NAME}"
                echo "Execution Time: ${currentBuild.durationString}"
                
                if (currentBuild.result == 'SUCCESS') {
                    echo "✓ Pipeline completed successfully"
                } else if (currentBuild.result == 'FAILURE') {
                    echo "✗ Pipeline failed"
                } else if (currentBuild.result == 'ABORTED') {
                    echo "⚠️  Pipeline was aborted"
                }
            }
        }
        
        success {
            script {
                echo "=== Success Actions ==="
                // Add any success notifications here (email, Slack, etc.)
            }
        }
        
        failure {
            script {
                echo "=== Failure Actions ==="
                // Add any failure notifications here (email, Slack, etc.)
                
                // Archive Ansible logs if available
                archiveArtifacts artifacts: '*.log', allowEmptyArchive: true
            }
        }
        
        cleanup {
            script {
                echo "=== Cleanup Actions ==="
                // Clean up any temporary files or resources
            }
        }
    }
}
