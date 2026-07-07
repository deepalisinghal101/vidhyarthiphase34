pipeline {

    agent any

    parameters {

        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose Terraform Action'
        )

    }

    environment {

        TF_DIR = 'Terraform-codes'
        ANSIBLE_DIR = 'ansible'

    }

    stages {

        stage('Clone Repository') {

            steps {

                echo "Cloning GitHub Repository..."

                git branch: 'main',
                    url: 'git@github.com:Rishikvashu/kafka-automation.git'
            }
        }

        stage('Terraform Init') {

            steps {

                dir("${TF_DIR}") {

                    sh '''
                    terraform init
                    '''
                }
            }
        }

        stage('Terraform Validate') {

            steps {

                dir("${TF_DIR}") {

                    sh '''
                    terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {

            steps {

                dir("${TF_DIR}") {

                    sh '''
                    terraform plan
                    '''
                }
            }
        }

        stage('Terraform Action') {

            steps {

                dir("${TF_DIR}") {

                    script {

                        if (params.ACTION == 'apply') {

                            echo "Creating Kafka Infrastructure..."

                            sh '''
                            terraform apply -auto-approve
                            '''

                        } else {

                            echo "Destroying Kafka Infrastructure..."

                            sh '''
                            terraform destroy -auto-approve
                            '''
                        }
                    }
                }
            }
        }

        stage('Wait for EC2') {

            when {

                expression {

                    return params.ACTION == 'apply'
                }
            }

            steps {

                echo "Waiting for EC2 to boot..."

                sleep(time: 60, unit: 'SECONDS')
            }
        }

        stage('Verify Dynamic Inventory') {

            when {

                expression {

                    return params.ACTION == 'apply'
                }
            }

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh '''
                    ansible-inventory --graph
                    '''
                }
            }
        }

        stage('Wait Until SSH is Ready') {

            when {

                expression {

                    return params.ACTION == 'apply'
                }
            }

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh '''
                    until ansible all -m ping
                    do
                        echo "Waiting for SSH..."
                        sleep 10
                    done
                    '''
                }
            }
        }

        stage('Configure Kafka Using Ansible') {

            when {

                expression {

                    return params.ACTION == 'apply'
                }
            }

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh '''
                    ansible-playbook site.yml
                    '''
                }
            }
        }

        stage('Verify Kafka Service') {

            when {

                expression {

                    return params.ACTION == 'apply'
                }
            }

            steps {

                dir("${ANSIBLE_DIR}") {

                    sh '''
                    ansible all -m shell -a "systemctl is-active kafka"
                    '''
                }
            }
        }
    }

    post {

        success {

            echo "=========================================="
            echo "Pipeline Executed Successfully"
            echo "=========================================="

        }

        failure {

            echo "=========================================="
            echo "Pipeline Failed"
            echo "=========================================="

        }

        always {

            echo "=========================================="
            echo "Pipeline Execution Finished"
            echo "=========================================="

        }
    }
}
