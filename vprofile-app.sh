#!/bin/bash

echo "🔹 Creating project structure..."

# Create directories
mkdir -p Graduation-Project/{db,nginx,tom-app,k8s}

# ================= Top-level files =================
echo "Creating Jenkinsfile..."
cat > Graduation-Project/Jenkinsfile <<'EOF'
pipeline {
    agent any
    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "708254703418.dkr.ecr.us-east-2.amazonaws.com/vprofile-app"
    }
    stages {
        stage('Checkout Code') {
            steps { git branch: 'main', url: 'https://github.com/Uliwazeer/Graduation-Project.git' }
        }
        stage('Build Docker Image') {
            steps { sh 'docker build -t vprofile-app:latest ./tom-app' }
        }
        stage('Login to ECR') {
            steps { sh 'aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}' }
        }
        stage('Push Image To ECR') {
            steps {
                sh 'docker tag vprofile-app:latest ${ECR_REPO}:${BUILD_NUMBER}'
                sh 'docker push ${ECR_REPO}:${BUILD_NUMBER}'
            }
        }
        stage('Update GitOps Repo') {
            steps {
                sh '''
                git clone https://github.com/Uliwazeer/gitops-vprofile.git
                cd gitops-vprofile
                sed -i "s|image: .*|image: ${ECR_REPO}:${BUILD_NUMBER}|g" deployment.yaml
                git commit -am "update image tag to ${BUILD_NUMBER}"
                git push
                '''
            }
        }
    }
}
EOF

echo "Creating docker-compose.yml..."
cat > Graduation-Project/docker-compose.yml <<'EOF'
version: '3.8'
services:
  nginx:
    build: ./nginx
    image: nginx-vp-app
    container_name: web
    ports:
      - "80:80"
      - "443:443"
    networks:
      - vp-app-network
    depends_on:
      - app01
  app01:
    build: ./tom-app
    image: tomcat-vp-app
    container_name: app01
    ports:
      - "8080:8080"
    networks:
      - vp-app-network
    depends_on:
      - db01
      - mc01
      - rmq01
  db01:
    build: ./db
    image: mysql-vp-app
    container_name: db01
    ports:
      - "3306:3306"
    networks:
      - vp-app-network
    volumes:
      - db_data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=admin123
      - MYSQL_USER=admin
      - MYSQL_DATABASE=accounts
  mc01:
    image: memcached
    container_name: mc01
    ports:
      - "11211:11211"
    networks:
      - vp-app-network
  rmq01:
    image: rabbitmq
    container_name: rmq01
    ports:
      - "5672:5672"
    networks:
      - vp-app-network
    environment:
      - RABBITMQ_DEFAULT_USER=guest
      - RABBITMQ_DEFAULT_PASS=guest
networks:
  vp-app-network:
    driver: bridge
volumes:
  db_data:
EOF

# ================= db =================
echo "Creating db/Dockerfile..."
cat > Graduation-Project/db/Dockerfile <<'EOF'
FROM mysql:8.0.44
ENV MYSQL_DATABASE="accounts"
ENV MYSQL_USER="admin"
ENV MYSQL_PASSWORD="admin123"
ADD db_backup.sql docker-entrypoint-initdb.d/db_backup.sql
EXPOSE 3306
CMD ["mysqld"]
EOF

echo "Creating db/db_backup.sql..."
cat > Graduation-Project/db/db_backup.sql <<'EOF'
-- Add your db schema and data here
EOF

# ================= nginx =================
echo "Creating nginx/Dockerfile..."
cat > Graduation-Project/nginx/Dockerfile <<'EOF'
FROM nginx:latest
WORKDIR /app
RUN rm -fr /etc/nginx/conf.d/default.conf
COPY . .
RUN chmod +x ./generate-ssl.sh && ./generate-ssl.sh && rm ./generate-ssl.sh
RUN mkdir -p /etc/nginx/ssl && \
    mv ./ssl/nginx.crt /etc/nginx/ssl/nginx.crt && \
    mv ./ssl/nginx.key /etc/nginx/ssl/nginx.key
COPY ./vp-app.conf /etc/nginx/conf.d/vp-app.conf
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
EOF

echo "Creating nginx/generate-ssl.sh..."
cat > Graduation-Project/nginx/generate-ssl.sh <<'EOF'
#!/bin/bash
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/nginx.key \
  -out ssl/nginx.crt \
  -subj "/C=eg/ST=cairo/L=cairo/O=MyProject/CN=localhost"
echo "✅ SSL certificate generated in ssl/"
EOF

chmod +x Graduation-Project/nginx/generate-ssl.sh

echo "Creating nginx/vp-app.conf..."
cat > Graduation-Project/nginx/vp-app.conf <<'EOF'
server {
    listen 80;
    server_name app01;
    return 301 https://$host$request_uri;
}
server {
    listen 443 ssl http2;
    server_name app01;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    location / {
        proxy_pass http://app01:8080;
    }
}
EOF

# ================= tom-app =================
echo "Creating tom-app/Dockerfile..."
cat > Graduation-Project/tom-app/Dockerfile <<'EOF'
FROM maven:3.8.4-openjdk-11 AS maven
WORKDIR /tmp
COPY application.properties /tmp/application.properties
RUN git clone -b Vagrant https://github.com/Omarh4700/Workshop.git && \
    cd Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr && \
    cp /tmp/application.properties ./src/main/resources/application.properties && \
    mvn clean install
FROM tomcat:9.0.75-jdk11 AS tomcat
RUN rm -fr /usr/local/tomcat/webapps/*
COPY --from=maven /tmp/Workshop/Vagrant-Manual-Automation/sourcecodeseniorwr/target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
EOF

echo "Creating tom-app/application.properties..."
cat > Graduation-Project/tom-app/application.properties <<'EOF'
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://db01:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin123

memcached.active.host=mc01
memcached.active.port=11211
memcached.standBy.host=mc01
memcached.standBy.port=11211

rabbitmq.address=rmq01
rabbitmq.port=5672
rabbitmq.username=guest
rabbitmq.password=guest

elasticsearch.host=vprosearch01
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

# ================= k8s =================
echo "Creating k8s/deployment.yaml..."
cat > Graduation-Project/k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vprofile
  namespace: vprofile
spec:
  replicas: 2
  selector:
    matchLabels:
      app: vprofile
  template:
    metadata:
      labels:
        app: vprofile
    spec:
      containers:
      - name: vprofile
        image: 708254703418.dkr.ecr.us-east-2.amazonaws.com/vprofile-app:latest
        ports:
        - containerPort: 8080
EOF

echo "Creating k8s/service.yaml..."
cat > Graduation-Project/k8s/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: vprofile
  namespace: vprofile
spec:
  selector:
    app: vprofile
  ports:
    - protocol: TCP
      port: 8080
      targetPort: 8080
  type: ClusterIP
EOF

echo "Creating k8s/ingress.yaml..."
cat > Graduation-Project/k8s/ingress.yaml <<'EOF'
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: vprofile-ingress
  namespace: vprofile
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: app01.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: vprofile
            port:
              number: 8080
EOF

echo "Creating k8s/namespace.yaml..."
cat > Graduation-Project/k8s/namespace.yaml <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: vprofile
EOF

echo "✅ All files created successfully!"

