pipeline {
    agent any

    environment {
        dockerImage = "thapavishal/javaapp"
    }

    stages {
        stage('Build java App') {
            // can also specify which stage to run on which node for each stage 
            agent{
                label 'ubuntu-pipeline-slave-node'
            }
            steps {
                sh 'mvn clean package'

            }
            post{
                success {
                    echo "Build completed, so archiving the war file"
                    archiveArtifacts artifacts: '**/*.war', followSymlinks: false
                }
            }
        }

        stage ('Docker Docker Image') {
            agent {
                label 'ubuntu-pipeline-slave-node'
            }
            steps {
                copyArtifacts filter: '**/*.war', fingerprintArtifacts: true, projectName: env.JOB_NAME, selector: specific(env.BUILD_NUMBER)
                echo "Building docker image"
                sh 'whoami'
                sh 'docker build -t $dockerImage:$BUILD_NUMBER .'
            }
        }
        stage('Push Image') {
            agent {
                label 'ubuntu-pipeline-slave-node'  
            }
                steps {
                    withDockerRegistry([credentialsId: 'dockerhub-credentials', url: '' ]) {
                        sh '''
                        docker push $dockerImage:$BUILD_NUMBER
                        '''

                    }
                }
        }
        stage('Deploy to Development Env') {
            agent 
            {
                label 'ubuntu-pipeline-slave-node'
        }
            steps {
                echo 'Running app on development env'
                sh '''
                docker stop tomcatinstanceDev || true
                docker rm tomcatinstanceDev || true
                docker run -itd --name tomcatinstanceDev -p 8082:8080 $dockerImage:$BUILD_NUMBER
                sh '''
            }
        }
        stage('Deploy Production Environment') {
            agent {
                label 'ubuntu-pipeline-slave-node'
            }
            steps {
                timeout(time:1, unit:'DAYS'){
                    input id: 'confirm', message: 'Approve deployment to production environment?'
                }
                echo "Running app on prod env"
                sh '''
                docker stop tomcatinstanceProd || true
                docker rm tomcatinstanceProd || true
                docker run -itd --name tomcatinstanceProd -p 8083:8080 $dockerImage:$BUILD_NUMBER
                '''
            }
        }
    }
    // post build actions
    post {
        always { 
            mail to: 'v01.thapa@gmail.com',
            subject: "Job '${JOB_NAME}' (${BUILD_NUMBER}) status",
            body: "Please go to ${BUILD_URL} and verify the build"
        }

        success{
            mail bcc: '', body: """Hi Team,
            Build #$BUILD_NUMBER is successful, please go through the url
            $BUILD_URL
            and verify the details.
            Regards,
            Devops Team""", cc: '', from: '', replyTo: '', subject: 'BUILD SUCCESS NOTIFICATION', to: 'v01.thapa@gmail.com'     
        }

        failure {
            mail bcc: '', body: """Hi Team,
            Build #$BUILD_NUMBER is unsuccessful, please go through the url
            $BUILD_URL
            and verify the details.
            Regards,
            Devops Team""", cc: '', from: '', replyTo: '', subject: 'BUILD FAILED NOTIFICATION', to: 'v01.thapa@gmail.com'     
        }
    }
}
