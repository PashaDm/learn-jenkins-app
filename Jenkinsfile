pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '0926e289-1b31-46dc-82d5-7e9180a045a3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {
        
        stage('Build') {
            agent {
                docker {
                    image 'node:18'
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

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    npm install netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Site ID: $NETLIFY_SITE_ID"  
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod
                    echo 'CHECK POLL!!!!'
                '''
            }
        }

        stage('PROD E2E') {
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
                        echo 'E2E Test stage '
                        sh '''
                            npx playwright test --reporter=html
                        '''
                    }

                    post {
                        always {                            
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright E2E', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
            }

    }


}
