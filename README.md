# MERN Image Gallery Todo Sample App

- Frontend: React, Bootstrap.
- Backend: Node.js, Express
- Database: Mongo (running locally for storing tasks)
- Object Storage: S3

## Project Structure

This project contains the following components:
- **/backend** - This directory contains the Node.js application that handles the server-side logic and interacts with the database. This directory contains configuration settings for uploading images to AWS S3. The uploadConfig.js file is responsible for configuring the S3 client to connect to the S3 endpoint. This allows the backend application to store and retrieve images associated with the image items.
- **/frontend** - The frontend directory contains the React application that handles the user interface and interacts with the backend. 

## How to run the App

### Pre-requisite
- Make sure that Docker is installed on your machine
- You have an AWS account and have acquired AWS Access key and Secret key
- You have created an AWS S3 bucket

### Create Docker Repo
1. Create **docker-compose** file

2. Build the image inside the **/backend** folder
```
docker-compose build
```

3. Push the container.
```
docker push <docker-username>/mern-backend:latest
```

4. Build the image using the Dockerfile inside the **/frontend** folder
```
docker buildx build -t <docker-username>/mern-frontend:latest .
```

5. Push the container.
```
docker push <docker-username>/mern-frontend:latest
```

### Build Terraform Code
1. Create the following file
```
  1.	main
  2.	vpc
  3.	ec2, variables
  4.	sg
  5.	s3
  6.	terraform.tfvars
  7.	outputs
```
> [!NOTE]  
> Make sure to change the name in **s3.tf** file
>
>  bucket = "s3-unique-global-name"    

2. Run terraform syntax
```
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

3. Update Private Route Table
```
Explicit subnet association = Private subnet
Add route to Internet (nat-instance)
Destination	        Target
0.0.0.0/0	          Instance (nat-instance) 
```
### Configure Ansible Playbook
1. Copy pem file inside the instances
```
scp -i <path of pem to enter> <path of pem to copy> ec2-user@<frontend-publicIP>:~/
```
If private instance
```
ssh -i ./devops.pem ec2-user@<proxy-public-ip>
scp -i <path of pem to enter> <path of pem to copy> ec2-user@<frontend-publicIP>:~/
```

2. ssh on Proxy server
```
ssh -i ./devops.pem ec2-user@<proxy-public-ip>
```

3. Install Ansible
```
sudo dnf install ansible -y
```

4. Create **inventory.ini** file
```
touch inventory.ini
vim inventory.ini
```

5. Update the IPs and SSH key. Update it locally then copy+paste it on vim
```
[frontend]
frontend-instance-1 ansible_host=10.0.1.182       #private ip
frontend-instance-2 ansible_host=10.0.1.244

[backend]
backend-instance-1 ansible_host=10.0.2.179
backend-instance-2 ansible_host=10.0.2.126
backend-instance-3 ansible_host=10.0.2.44

[mongo]
mongodb-server ansible_host=10.0.2.87

[variables]
ansible_user=ec2-user   
ansible_ssh_private_key_file=./devops.pem
```

6. Check Ansible Connections to other Instances/Server
```
ansible all -i inventory.ini -m ping
```

7. Create Backend, Frontend and Mongodb Ansible Playbook

8. Deploy Applications via Ansible Playbook
## Deploy Applications via Ansible Playbook
1. git clone the updated folder, where you can see the ansible playbook files

2. Run Instance setup
```
ansible-playbook -i inventory.ini ./v5/mern-gallery-sample-app/instance.yaml
```

3. Run Mongodb server
```
ansible-playbook -i inventory.ini ./v5/mern-gallery-sample-app/mongodb.yaml --limit mongo
```

4. Update **.env** file in /backend
```
cd backend
vim .env
```
```
MONGODB_URI=mongodb://<MongoDB EC2 Private IP>:27017/todos
AWS_ACCESS_KEY_ID=<Your IAM Access Key>
AWS_SECRET_ACCESS_KEY=<Your IAM Secret Key>
S3_BUCKET_NAME=<Your S3 Bucket Name>
AWS_REGION=us-east-1
```

5. Run Backend servers
```
ansible-playbook -i inventory.ini ./v5/mern-gallery-sample-app/backend.yaml --limit backend
```

6. Run Frontend servers
```
ansible-playbook -i inventory.ini ./v5/mern-gallery-sample-app/frontend.yaml --limit frontend
```

7. Update **default.conf** file
```
cat /etc/nginx/conf.d/default.conf
vim /etc/nginx/conf.d/default.conf
```
```
upstream frontend_app {
    server 10.0.1.182:3000;  # frontend-instance-1
    server 10.0.1.244:3000;  # frontend-instance-2
}

upstream backend_api {
    server 10.0.2.179:5000;
    server 10.0.2.126:5000;
    server 10.0.2.2:5000;
}

server {
    listen 80 default_server;
    server_name _;

    location / {
        proxy_pass http://frontend_app/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_cache_bypass $http_upgrade;
    }

    location /api/ {
        proxy_pass http://backend_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
```
7. Restart nginx
```
sudo systemctl restart nginx
```

## Access the Application in Browser
1. Get the NLB DNS Name 
```
EC2>Load Balancer >DNS name
example:  Public-NLB-TG-5616af283cd641f6.elb.us-east-1.amazonaws.com
```

# Terraform Destroy
```
terraform destroy -auto-approve
```