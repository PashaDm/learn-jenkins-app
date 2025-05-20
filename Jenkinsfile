pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '0926e289-1b31-46dc-82d5-7e9180a045a3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }

    stages {
        
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
                        sh '''
                            npm install netlify-cli node-jq
                            node_modules/.bin/netlify --version
                            echo 'Deploy to STG'
                            echo "Site ID: $NETLIFY_SITE_ID"  
                            node_modules/.bin/netlify status
                            node_modules/.bin/netlify deploy --dir=build --json > deploy-output.json
                            CI_ENVIRONMENT_URL=$(node_modules/.bin/node-jq -r ".deploy_url" deploy-output.json)                            
                            npx playwright test --reporter=html
                        '''
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

        stage('Deploy prod') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'https://celadon-moonbeam-666fd1.netlify.app'
                    }

                    steps {                        
                        sh '''
                            node --version 
                            npm install netlify-cli
                            node_modules/.bin/netlify --version
                            echo 'Deploy to PROD'
                            echo "Site ID: $NETLIFY_SITE_ID"  
                            node_modules/.bin/netlify status
                            node_modules/.bin/netlify deploy --dir=build --prod
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {                            
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Production E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
            }

    }


}
