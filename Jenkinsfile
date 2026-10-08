pipeline {

    agent any

    options {

        timestamps()

        disableConcurrentBuilds()

        buildDiscarder(
            logRotator(
                numToKeepStr: '20'
            )
        )

        timeout(
            time: 30,
            unit: 'MINUTES'
        )
    }

    environment {

        APP_NAME = 'taskflow'

        FRONTEND_IMAGE = "taskflow-frontend:${BUILD_NUMBER}"

        BACKEND_IMAGE = "taskflow-backend:${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {

            steps {

                checkout scm

                script {

                    env.GIT_SHA = sh(
                        script: 'git rev-parse --short=12 HEAD',
                        returnStdout: true
                    ).trim()

                }

                echo "Git SHA: ${env.GIT_SHA}"
                echo "Build Number: ${env.BUILD_NUMBER}"
            }
        }


        stage('Validate') {

            steps {

                sh '''
                    set -e

                    echo "Validating project..."

                    test -f frontend/package.json
                    test -f frontend/Dockerfile
                    #test -f frontend/nginx.conf

                    test -f backend/requirements.txt
                    test -f backend/Dockerfile
                    test -f backend/app/main.py

                    test -f docker-compose.yml

                    echo "Validation successful."
                '''
            }
        }


        stage('Build Docker Images') {

            steps {

                sh '''
                    set -e

                    echo "Building frontend..."

                    docker build \
                        -t ${FRONTEND_IMAGE} \
                        ./frontend


                    echo "Building backend..."

                    docker build \
                        -t ${BACKEND_IMAGE} \
                        ./backend
                '''
            }
        }


        stage('Deploy DEV') {

            steps {

                sh '''
                    set -e

                    docker compose down

                    docker compose up -d

                    echo "DEV deployment completed."
                '''
            }
        }


        stage('Smoke Test') {

            steps {

                sh '''
                    set -e

                    echo "Waiting for application..."

                    sleep 10


                    echo "Checking backend..."

                    curl --fail \
                        http://localhost:8000/health


                    echo "Checking API..."

                    curl --fail \
                        http://localhost:3000/api/tasks


                    echo "Checking frontend..."

                    curl --fail \
                        http://localhost:3000


                    echo "Smoke tests passed."
                '''
            }
        }


        stage('Production Approval') {

            steps {

                input message:
                    "Deploy TaskFlow Build ${BUILD_NUMBER} to production?",
                    ok: "Deploy"
            }
        }


        stage('Deploy PROD') {

            steps {

                echo "Production deployment will be implemented next."

                // Later:
                // sh './scripts/deploy.sh prod'
            }
        }
    }


    post {

        success {

            echo """
            ======================================
            TASKFLOW PIPELINE SUCCESS
            ======================================

            Build     : ${BUILD_NUMBER}
            Git SHA   : ${GIT_SHA}

            Frontend  : ${FRONTEND_IMAGE}
            Backend   : ${BACKEND_IMAGE}

            ======================================
            """
        }

        failure {

            echo """
            ======================================
            TASKFLOW PIPELINE FAILED
            ======================================

            Build   : ${BUILD_NUMBER}
            Git SHA : ${GIT_SHA}

            Check Jenkins logs.

            ======================================
            """
        }

        always {

            cleanWs()
        }
    }
}
