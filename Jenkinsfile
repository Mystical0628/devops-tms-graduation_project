// def awsAccessKey = timeout(time:60, unit:'SECONDS') {
// 	input(id: 'awsAccessKey', message: 'AWS Access Key Required', parameters: [
// 		[
// 			$class: 'TextParameterDefinition',
// 			defaultValue: '',
// 			description: 'Access Key',
// 			name: 'access_key'
// 		],
//   ])
// }
//
// def awsSecretKey = timeout(time:60, unit:'SECONDS') {
// 	input(id: 'awsSecretKey', message: 'AWS Secret Key Required', parameters: [
// 		[
// 			$class: 'TextParameterDefinition',
// 			defaultValue: '',
// 			description: 'Secret Key',
// 			name: 'secret_key'
// 		],
//   ])
// }

pipeline {
  agent any

  //environment {
//     AWS_ACCESS_KEY_TEST = credentials('aws')
    //AWS_ACCESS_KEY = credentials('jenkins-aws-secret-key-id')
    //AWS_SECRET_KEY = credentials('jenkins-aws-secret-access-key')
//     TF_IN_AUTOMATION = 'true'
//     TF_CLI_CONFIG_FILE = credentials('tf-creds')
//     AWS_SHARED_CREDENTIALS_FILE='/home/ubuntu/.aws/credentials'
  //}

	tools {
		terraform 'terraform'
	}

  stages {
    stage('Debug') {
      steps {
        dir('infrastructure') {
          sh 'echo $AWS_ACCESS_KEY_ID'
          sh 'echo "$AWS_ACCESS_KEY_ID"'
          sh 'echo ${AWS_ACCESS_KEY_ID}'
          sh 'echo "${AWS_ACCESS_KEY_ID}"'
          sh 'echo $AWS_SECRET_ACCESS_KEY'
          sh 'echo "$AWS_SECRET_ACCESS_KEY"'
          sh 'echo ${AWS_SECRET_ACCESS_KEY}'
          sh 'echo "${AWS_SECRET_ACCESS_KEY}"'
//           sh 'echo $AWS_ACCESS_KEY_TEST'
//           sh 'echo "$AWS_ACCESS_KEY_TEST"'
//           sh 'echo ${AWS_ACCESS_KEY_TEST}'
//           sh 'echo "${AWS_ACCESS_KEY_TEST}"'
//           sh 'echo $AWS_ACCESS_KEY'
//           sh 'echo "$AWS_ACCESS_KEY"'
//           sh 'echo ${AWS_ACCESS_KEY}'
//           sh 'echo "${AWS_ACCESS_KEY}"'
        }
      }
    }

    stage('Init') {
      steps {
        dir('infrastructure') {
	        sh 'ls'
	        sh 'cat tfvars/$BRANCH_NAME.tfvars'
	        sh "terraform init -reconfigure -no-color -backend-config=\"access_key=${awsAccessKey}\" -backend-config=\"secret_key=${awsSecretKey}\""
        }
      }
    }

    stage('Plan') {
      steps {
        dir('infrastructure') {
          sh """
            terraform plan \
              -no-color \
              -var-file="tfvars/\$BRANCH_NAME.tfvars" \
              -var='access_key=${awsAccessKey}' \
              -var='secret_key=${awsSecretKey}'
          """
        }
      }
    }

    stage('Confirm Apply') {
      when {
        beforeInput true
        branch "master"
      }
      input {
        message "Do you want to apply this plan?"
        ok "Apply plan"
      }
      steps {
	       echo 'Apply Accepted'
      }
    }

    stage('Apply') {
      steps {
        dir('infrastructure') {
          sh """
            terraform apply \
              -auto-approve \
              -no-color \
              -var-file="tfvars/\$BRANCH_NAME.tfvars" \
              -var='access_key=${awsAccessKey}' \
              -var='secret_key=${awsSecretKey}'
          """
        }
      }
    }

    stage('Confirm Ansible') {
      when {
        beforeInput true
        branch "master"
      }
      input {
        message "Do you want to run Ansible?"
        ok "Run Ansible"
      }
      steps {
        echo 'Ansible Approved'
      }
    }

    stage('EC2 Wait') {
      steps {
        sh """
          aws ec2 wait instance-status-ok \
            --instance-ids \$(terraform output instance_id-jenkins_agent) \$(terraform output instance_id-nginx) \
            --region us-east-1a
        """
      }
    }

    stage('Inventory') {
      steps {
        dir('infrastructure') {
	        sh """
	          printf "
[jenkins_agents]
\$(terraform output -raw instance_ip-jenkins_agent)

[nginx]
\$(terraform output -raw instance_ip-nginx)
	          " > ../configure/hosts
	        """
	      }
      }
    }


//
//     stage('Ansible') {
//       steps {
//         ansiblePlaybook(credentialsId: 'ec2-ssh-key', inventory: 'aws_hosts', playbook: 'playbooks/docker.yml')
//       }
//     }
//
//     stage('Validate Destroy') {
//       input {
//         message "Do you want to destroy?"
//         ok "Destroy"
//         }
//       steps {
//         echo 'Destroy Approved'
//       }
//     }
//
//     stage('Destroy') {
//       steps {
//         sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
//       }
//     }

  }

  post {
    success {
      echo 'Success!'
    }

//     failure {
//       sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
//     }
//
//     aborted {
//       sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
//     }
  }
}