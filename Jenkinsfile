pipeline {
  agent any

  environment {
    // Replace these with Jenkins credentials or job params as needed
    AWS_REGION       = credentials('aws-region')      // secret text containing region (e.g., us-east-1)
    AWS_ACCOUNT_ID   = credentials('aws-account-id') // secret text containing account id
    ECR_REPO         = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/webapp-game"
    IMAGE_TAG        = "${env.BUILD_NUMBER ?: 'local-' + sh(returnStdout: true, script: 'date +%s').trim()}"
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '30'))
    timeout(time: 60, unit: 'MINUTES')
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/maazmohemmed/eks-web-game-java.git', changelog: false, poll: false
      }
    }

    stage('Build (Maven)') {
      steps {
        sh 'mvn -version || true'
        sh 'mvn -B -DskipTests clean package'
      }
    }

    stage('Prepare CLIs') {
      steps {
        sh '''
          which aws || (apt-get update -y && apt-get install -y python3-pip curl || apk add --no-cache python3 py3-pip curl) || true
          which aws || pip3 install --user awscli
          which kubectl || (curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x kubectl && mv kubectl /usr/local/bin/)
        '''
      }
    }

    stage('Docker Build & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'aws-ecr-credentials', usernameVariable: 'AWS_USER', passwordVariable: 'AWS_PASS'),
                         string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                         string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
          sh '''
            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
            export AWS_DEFAULT_REGION=${AWS_REGION}

            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
            aws ecr describe-repositories --repository-names webapp-game --region ${AWS_REGION} >/dev/null 2>&1 || aws ecr create-repository --repository-name webapp-game --region ${AWS_REGION}

            docker build -t ${ECR_REPO}:${IMAGE_TAG} .
            docker push ${ECR_REPO}:${IMAGE_TAG}
          '''
        }
      }
    }

    stage('Deploy to EKS') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig-id', variable: 'KUBECONFIG_FILE')]) {
          sh '''
            export KUBECONFIG=${KUBECONFIG_FILE}
            kubectl -n public set image deployment/webapp-game webapp-game=${ECR_REPO}:${IMAGE_TAG} --record || echo "public deploy update skipped"
            kubectl -n private set image deployment/webapp-game webapp-game=${ECR_REPO}:${IMAGE_TAG} --record || echo "private deploy update skipped"
            kubectl -n public rollout status deployment/webapp-game --timeout=120s || true
            kubectl -n private rollout status deployment/webapp-game --timeout=120s || true
          '''
        }
      }
    }
  }

  post {
    always { cleanWs() }
    failure { echo "Build failed" }
    success { echo "Finished: ${ECR_REPO}:${IMAGE_TAG}" }
  }
}
