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

  parameters {
    booleanParam(name: 'DESTROY_TERRAFORM', defaultValue: false, description: 'Destroy Terraform')
    booleanParam(name: 'RUN_TERRAFORM', defaultValue: true, description: 'Run Terraform')
    booleanParam(name: 'RUN_WAIT_AND_ACQUAINT', defaultValue: true, description: 'Wait EC2 and Acquaint')
    booleanParam(name: 'RUN_ANSIBLE', defaultValue: true, description: 'Run Ansible')
  }

  stages {
    stage('Destroy') {
      when {
        expression { return params.DESTROY_TERRAFORM }
      }

      steps {
		    dir('infrastructure') {
	        sh 'terraform destroy \
	          -auto-approve \
	          -no-color \
	          -var-file="tfvars/$BRANCH_NAME.tfvars" \
		        -var="access_key=$AWS_SECRET_ACCESS_KEY" \
		        -var="secret_key=$AWS_SECRET_KEY_ID" '
	      }
      }
    }

    stage('Terraform') {
      when {
        expression { return params.RUN_TERRAFORM }
      }

      stages {
		    stage('Init') {
		      steps {
		        dir('infrastructure') {
			        sh 'ls'
			        sh 'cat tfvars/$BRANCH_NAME.tfvars'
			        sh 'terraform init \
			          -reconfigure \
			          -no-color \
			          -backend-config="access_key=$AWS_SECRET_ACCESS_KEY" \
			          -backend-config="secret_key=$AWS_SECRET_KEY_ID" '
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
        expression { return params.RUN_WAIT_AND_ACQUAINT }
      }

      stages {
		    stage('EC2 Wait') {
		      steps {
		        dir('infrastructure') {
			        sh """
			          aws ec2 wait instance-status-ok \
			            --instance-ids \$(terraform output -raw instance_id-jenkins_agent) \$(terraform output -raw instance_id-nginx) \$(terraform output -raw instance_id-app) \
			            --region us-east-1
			        """
			      }
		      }
		    }

		    stage('Acquaint') {
		      steps {
		        dir('infrastructure') {
			        sh 'cp $JENKINS_KNOWN_HOSTS $JENKINS_KNOWN_HOSTS.old'
			        sh 'ssh-keyscan \$(terraform output -raw instance_ip-jenkins_agent) >> $JENKINS_KNOWN_HOSTS'
			        sh 'ssh-keyscan \$(terraform output -raw instance_ip-nginx) >> $JENKINS_KNOWN_HOSTS'
			      }
		      }
		    }
      }
    }


    stage('Ansible') {
      when {
        expression { return params.RUN_ANSIBLE }
      }

			stages {
		    stage('Inventory') {
		      steps {
		        dir('infrastructure') {
			        sh """
			          printf "
all:
	hosts:
		jenkins_agents:
			ansible_host: \$(terraform output -raw instance_ip-jenkins_agent)

		nginx:
	    ansible_host: \$(terraform output -raw instance_ip-nginx)
	    app_host: \$(terraform output -raw instance_ip-app)
			          " > ../configure/hosts.yaml
			        """
			      }
		      }
		    }

				stage('Playbooks') {
		      parallel {
				    stage('Playbook: Jenkins agents') {
				      steps {
				        dir('configure') {
				          ansiblePlaybook credentialsId: 'ec2-ssh-key', inventory: 'hosts.yaml', playbook: 'jenkins_agents.yaml'
				        }
				      }
				    }

				    stage('Playbook: Nginx') {
				      steps {
				        dir('configure') {
				          ansiblePlaybook credentialsId: 'ec2-ssh-key', inventory: 'hosts.yaml', playbook: 'nginx.yaml'
				        }
				      }
				    }
		      }
		    }
	    }
    }
  }

  post {
    success {
      echo 'Success!'
    }
  }
}