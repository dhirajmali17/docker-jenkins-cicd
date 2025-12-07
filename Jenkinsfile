pipeline {
  /* Run on your worker node that has Docker installed */
  agent { label 'slave-1' }

  environment {
    DOCKERHUB_USER = 'dhiraj1725'
    IMAGE_REPO     = 'docker-jenkins'
    IMAGE_TAG      = 'latest'
    CONTAINER_NAME = 'myhttpd'
    HOST_PORT      = '8080'
    CONTAINER_PORT = '80'
  }

  triggers {
    pollSCM('* * * * *') // same frequent polling you used (*/1 * * * *)
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build image') {
      steps {
        sh '''
          echo "Building Docker image..."
          docker build -t ${DOCKERHUB_USER}/${IMAGE_REPO}:${IMAGE_TAG} .
        '''
      }
    }

    stage('Login to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub_cred',
                                          usernameVariable: 'DH_USER',
                                          passwordVariable: 'DH_PASS')]) {
          sh 'echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin'
        }
      }
    }

    stage('Push image') {
      steps {
        sh '''
          echo "Pushing image to Docker Hub..."
          docker push ${DOCKERHUB_USER}/${IMAGE_REPO}:${IMAGE_TAG}
        '''
      }
    }

    stage('Deploy container') {
      steps {
        sh '''
          set -e
          # stop & remove existing container if present
          if docker ps -aq -f name=${CONTAINER_NAME} | grep -q . ; then
            echo "Stopping and removing old container..."
            docker rm -f ${CONTAINER_NAME} || true
          fi
          # run new container
          echo "Starting container ${CONTAINER_NAME}..."
          docker run -d --name ${CONTAINER_NAME} -p ${HOST_PORT}:${CONTAINER_PORT} ${DOCKERHUB_USER}/${IMAGE_REPO}:${IMAGE_TAG}
          echo "Website available at http://<your-server-ip>:${HOST_PORT}"
        '''
      }
    }
  }

  post {
    always {
      sh 'docker logout || true'
    }
  }
}
