#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${PWD}/ansible-k8s-project"

echo "Creating project skeleton at: $ROOT_DIR"
mkdir -p "$ROOT_DIR"
cd "$ROOT_DIR"

# -------------------------
# ansible.cfg
# -------------------------
cat > ansible.cfg <<'EOF'
[defaults]
inventory = inventory.ini
host_key_checking = False
remote_user = ubuntu
retry_files_enabled = False
EOF

# -------------------------
# inventory.ini
# -------------------------
cat > inventory.ini <<'EOF'
[masters]
master-k8s ansible_host=3.137.41.5 ansible_user=ubuntu

[workers]
worker-1 ansible_host=18.222.43.140 ansible_user=ubuntu

[k8s:children]
masters
workers
EOF

# -------------------------
# group_vars/all.yml
# -------------------------
mkdir -p group_vars
cat > group_vars/all.yml <<'EOF'
---
aws_region: us-east-2
ssh_user: ubuntu
EOF

# -------------------------
# main.yml
# -------------------------
cat > main.yml <<'EOF'
---
- hosts: all
  become: true
  roles:
    - k8s_common

- hosts: masters
  become: true
  roles:
    - k8s_master

- hosts: workers
  become: true
  roles:
    - k8s_worker

- hosts: masters
  become: true
  roles:
    - jenkins
    - argocd
    - prometheus_stack
EOF

# -------------------------
# Roles structure
# -------------------------
mkdir -p roles/k8s_common/tasks
mkdir -p roles/k8s_master/tasks
mkdir -p roles/k8s_worker/tasks
mkdir -p roles/jenkins/tasks roles/jenkins/templates
mkdir -p roles/argocd/tasks
mkdir -p roles/prometheus_stack/tasks

# -------------------------
# k8s_common/tasks/main.yml
# -------------------------
cat > roles/k8s_common/tasks/main.yml <<'EOF'
---
- name: Update apt cache
  apt:
    update_cache: yes
    cache_valid_time: 3600

- name: Disable swap
  command: swapoff -a
  ignore_errors: yes

- name: Install Docker
  apt:
    name: docker.io
    state: present

- name: Enable Docker service
  systemd:
    name: docker
    enabled: true
    state: started

- name: Add Kubernetes repo
  apt_repository:
    repo: deb http://apt.kubernetes.io/ kubernetes-xenial main

- name: Install kubeadm, kubelet, kubectl
  apt:
    name:
      - kubelet
      - kubeadm
      - kubectl
    state: present
    update_cache: yes

- name: Hold kube packages
  apt:
    name:
      - kubelet
      - kubeadm
      - kubectl
    state: present
    update_cache: yes
EOF

# -------------------------
# k8s_master/tasks/main.yml
# -------------------------
cat > roles/k8s_master/tasks/main.yml <<'EOF'
---
- name: Initialize Kubernetes master
  command: kubeadm init --pod-network-cidr=10.244.0.0/16
  register: kubeadm_init
  args:
    creates: /etc/kubernetes/admin.conf

- name: Set up kubeconfig for ubuntu
  copy:
    src: /etc/kubernetes/admin.conf
    dest: /home/ubuntu/.kube/config
    remote_src: yes
    owner: ubuntu
    group: ubuntu
    mode: '0644'

- name: Install Flannel CNI
  command: kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

- name: Save kubeadm join command
  set_fact:
    kubeadm_join_command: "{{ kubeadm_init.stdout_lines | select('search', 'kubeadm join') | list | first }}"
EOF

# -------------------------
# k8s_worker/tasks/main.yml
# -------------------------
cat > roles/k8s_worker/tasks/main.yml <<'EOF'
---
- name: Join the node to the cluster
  command: "{{ hostvars['master-k8s']['kubeadm_join_command'] }}"
  when: hostvars['master-k8s']['kubeadm_join_command'] is defined
EOF

# -------------------------
# Jenkins role (placeholder)
# -------------------------
cat > roles/jenkins/tasks/main.yml <<'EOF'
---
- name: Ensure helm is installed
  debug:
    msg: "Install Helm here"

- name: Deploy Jenkins
  debug:
    msg: "Apply Jenkins Deployment/Service"
EOF

cat > roles/jenkins/templates/jenkins-deployment.yml.j2 <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins
        image: jenkins/jenkins:lts
        ports:
        - containerPort: 8080
EOF

cat > roles/jenkins/templates/jenkins-service.yml.j2 <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: jenkins
spec:
  type: NodePort
  selector:
    app: jenkins
  ports:
  - protocol: TCP
    port: 8080
    targetPort: 8080
EOF

# -------------------------
# ArgoCD role (placeholder)
# -------------------------
cat > roles/argocd/tasks/main.yml <<'EOF'
---
- name: Add ArgoCD helm repo
  debug:
    msg: "helm repo add argocd"

- name: Install ArgoCD
  debug:
    msg: "helm install argocd"
EOF

# -------------------------
# Prometheus role (placeholder)
# -------------------------
cat > roles/prometheus_stack/tasks/main.yml <<'EOF'
---
- name: Add prometheus helm repo
  debug:
    msg: "helm repo add prometheus-community"

- name: Install kube-prometheus-stack
  debug:
    msg: "helm install prometheus (kube-prometheus-stack)"
EOF

# -------------------------
# README.md
# -------------------------
cat > README.md <<'EOF'
Ansible project for 2-node Kubernetes cluster (master + worker)

Steps:
1. Run: ansible-playbook -i inventory.ini main.yml
2. This will:
   - Install Docker and kube packages
   - Init master
   - Join worker
   - Install Jenkins, ArgoCD, Prometheus stack (placeholders)
EOF

echo "Done. Project skeleton and files created."
echo "cd $ROOT_DIR && tree -a"

