pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '0926e289-1b31-46dc-82d5-7e9180a045a3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {       
        /*    
        stage('AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                }
            }
            environment {
                AWS_S3_BUCKET = 'learn-jenkins-202506092300'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        echo "Hello S3!!!" > index.html
                        aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
                    '''
                }

            }
        }
        */
        stage('Docker') {
            steps {
                sh 'docker build -t my-playwright .'
            }
        }

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        
        stage('Tests') {
            parallel {
                stage('Unit Tests') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            if test -f 'build/index.html'; then
                                echo "File exists"
                            else
                                echo "File does not exist"
                            fi
                            npm test
                        '''
                    }

                    post {
                        always {
                            junit 'jest-results/junit.xml'                            
                        }
                    }
                }
                
                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    steps {
                        echo 'E2E Test stage '
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {
                            
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }
        
        stage('Deploy staging') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    environment {
                        CI_ENVIRONMENT_URL = 'STG_URL_TO_BE_SET'
                    }
                    steps {
                        echo 'E2E Test stage '
                        steps {                           
                            sh '''
                                npm install netlify-cli node-jq
                                node_modules/.bin/netlify --version
                                echo "Site ID: $NETLIFY_SITE_ID"  
                                node_modules/.bin/netlify status
                                node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                                CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json)                            
                                npx playwright test --reporter=html
                            '''                        
                      }
                    }
                    post {
                        always {                            
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
         }
        /*  
        stage('Approval') {
            steps {
                timeout(time: 5, unit: 'SECONDS') {
                    input message: 'Ready to deploy to Prod?', ok: 'Yes, I am sure!'
                }
            }
        } */
        /*
        stage('Deploy prod') {
                    agent {
                        docker {
                            image 'my-playwright:latest'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'https://celadon-moonbeam-666fd1.netlify.app'
                    }

                    steps {                        
                        sh '''
                            node --version 
                            netlify --version
                            echo 'Deploy to PROD'
                            echo "Site ID: $NETLIFY_SITE_ID"  
                            netlify status
                            netlify deploy --dir=build --prod
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {                            
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Production E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
            }
    */
    }
    
}
