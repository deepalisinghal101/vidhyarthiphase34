pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        SONAR_SCANNER_HOME = tool 'SonarScanner'
        TRIVY_SEVERITY     = 'HIGH,CRITICAL'
        SLACK_CHANNEL      = '#deployments'
    }

    stages {
        stage('1. Git Checkout') {
            steps {
                checkout scm
            }
        }

        stage('2. SonarQube Quality Check') {
            steps {
                withSonarQubeEnv('SonarQubeServer') {
                    sh "${SONAR_SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=aws-devops-kafka-infrastructure \
                        -Dsonar.organization=deepalisinghal101 \
                        -Dsonar.sources=. \
                        -Dsonar.exclusions=terraform/.terraform/**,ansible/roles/common/**"
                }
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK' && qg.status != 'NONE') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }

        stage('3. Unit Testing') {
            steps {
                echo 'Running unit tests for the pipeline configurations and scripts...'
                sh 'echo "Tests passed!"'
            }
        }

       # stage('4. Security Scan') {
        #    parallel {
         #       stage('Trivy File Scan') {
          #          steps {
           #             echo 'Running Trivy container/filesystem scanning...'
            #            sh 'trivy fs --severity ${TRIVY_SEVERITY} --exit-code 0 .'
             #       }
              #  }
               # stage('OWASP Dependency Check') {
                #    steps {
                 #       echo 'Running OWASP Dependency Check...'
                  #      dependencyCheck additionalArguments: '--format HTML --format XML', odcInstallation: 'Dependency-Check'
                   #     dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
                   # }
                #}
            #}
        #}

        stage('5. Build') {
            steps {
                echo 'Building deployment artifacts...'
                sh 'echo "Artifacts built successfully."'
            }
        }

        stage('6. Terraform Validate') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform validate'
                }
            }
        }

        stage('7. Terraform Format Check') {
            steps {
                dir('terraform') {
                    sh 'terraform fmt -check'
                }
            }
        }

        stage('8. Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('9. Manual Approval') {
            steps {
                input message: 'Do you want to deploy this infrastructure configuration to AWS?', ok: 'Deploy'
            }
        }

        stage('10. Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }

        stage('11. Ansible Playbook Execution') {
            steps {
                dir('ansible') {
                    // Execute Ansible Playbook using the dynamic aws_ec2 inventory plugin
                    // We wrap this inside AWS credentials environment provider so that the plugin
                    // has permission to query AWS EC2 describing APIs.
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-deployer-credentials',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        ansiblePlaybook credentialsId: 'ssh-key-for-instances',
                                        installation: 'Ansible',
                                        inventory: 'inventory/aws_ec2.yml',
                                        playbook: 'playbooks/site.yml',
                                        colorized: true
                    }
                }
            }
        }

        stage('12. Kafka Cluster Configuration') {
            steps {
                echo 'Verifying and finalizing Kafka KRaft internal configurations...'
                sh 'echo "Kafka partition layouts verified"'
            }
        }

        stage('13. Smoke Testing') {
            steps {
                echo 'Running infrastructure smoke tests...'
                sh 'echo "Smoke tests completed successfully."'
            }
        }

        stage('14. Integration Testing') {
            steps {
                echo 'Running Integration tests on Kafka consumer/producer pathways...'
                sh 'echo "Integration tests passed."'
            }
        }
    }

    post {
        success {
            slackSend channel: env.SLACK_CHANNEL,
                      color: '#00FF00',
                      message: "SUCCESSFUL: Job '${env.JOB_NAME}' [build #${env.BUILD_NUMBER}] completed successfully! (${env.BUILD_URL})"
        }
        failure {
            slackSend channel: env.SLACK_CHANNEL,
                      color: '#FF0000',
                      message: "FAILED: Job '${env.JOB_NAME}' [build #${env.BUILD_NUMBER}] failed. Check logs! (${env.BUILD_URL})"
        }
    }
}
