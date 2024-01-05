pipeline {
  agent any

	tools {
		terraform 'terraform'
		ansible 'ansible'
	}

  environment {
    AWS_SECRET_ACCESS_KEY = credentials('aws_secret_access_key')
    AWS_SECRET_KEY_ID = credentials('aws_secret_key_id')
    JENKINS_KNOWN_HOSTS = "/var/lib/jenkins/.ssh/known_hosts"
  }

  stages {
    stage('Start') {
      input {
        message 'Choose options'
        ok 'Run'
			  parameters {
			    booleanParam(name: 'run_terraform', defaultValue: true, description: 'Run Terraform')
			    booleanParam(name: 'run_wait_and_acquaint', defaultValue: true, description: 'Wait EC2 and Acquaint')
			    booleanParam(name: 'run_ansible', defaultValue: true, description: 'Run Ansible')
			  }
      }

      steps {
        echo 'Start'
      }
    }

    stage('Terraform') {
      when {
        expression {
          return params.run_terraform
        }
      }

      stages {
		    stage('Init') {
		      steps {
		        dir('infrastructure') {
			        sh 'ls'
			        sh 'cat tfvars/$BRANCH_NAME.tfvars'
			        sh 'terraform init -reconfigure -no-color -backend-config="access_key=$AWS_SECRET_ACCESS_KEY" -backend-config="secret_key=$AWS_SECRET_KEY_ID"'
		        }
		      }
		    }

		    stage('Plan') {
		      steps {
		        dir('infrastructure') {
		          sh 'terraform plan \
		            -no-color \
		            -var-file="tfvars/$BRANCH_NAME.tfvars" \
		            -var="access_key=$AWS_SECRET_ACCESS_KEY" \
		            -var="secret_key=$AWS_SECRET_KEY_ID" '
		        }
		      }
		    }

		    stage('Confirm plan') {
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
		          sh 'terraform apply \
		            -auto-approve \
		            -no-color \
		            -var-file="tfvars/$BRANCH_NAME.tfvars" \
		            -var="access_key=$AWS_SECRET_ACCESS_KEY" \
		            -var="secret_key=$AWS_SECRET_KEY_ID" '
		        }
		      }
		    }
      }
    }


    stage('EC2 Wait and Acquaint') {
      when {
        expression {
          return params.run_wait_and_acquaint
        }
      }

      stages {
		    stage('EC2 Wait') {
		      steps {
		        dir('infrastructure') {
			        sh """
			          aws ec2 wait instance-status-ok \
			            --instance-ids \$(terraform output -raw instance_id-jenkins_agent) \$(terraform output -raw instance_id-nginx) \
			            --region us-east-1
			        """
			      }
		      }
		    }

		    stage('Acquaint') {
		      steps {
		        dir('infrastructure') {
// 			        sh 'cp $JENKINS_KNOWN_HOSTS $JENKINS_KNOWN_HOSTS.old'
// 			        sh 'ssh-keyscan \$(terraform output -raw instance_ip-jenkins_agent) >> $JENKINS_KNOWN_HOSTS'
// 			        sh 'ssh-keyscan \$(terraform output -raw instance_ip-nginx) >> $JENKINS_KNOWN_HOSTS'
			        sh 'echo "\$(terraform output -raw instance_ip-jenkins_agent)"'
			        sh 'cat $JENKINS_KNOWN_HOSTS'
			      }
		      }
		    }
      }
    }


    stage('Ansible') {
      when {
        expression {
          return params.run_ansible
        }
      }

      stages {
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

		    stage('Ansible') {
		      steps {
		        dir('configure') {
		          ansiblePlaybook credentialsId: 'ec2-ssh-key', inventory: 'hosts', playbook: 'playbook.yaml'
		        }
		      }
		    }
      }
    }

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