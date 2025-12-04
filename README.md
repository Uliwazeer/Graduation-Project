# Graduation Project: VProfile 5-Tier Microservices Application with Jenkins CI & GitOps CD via ArgoCD

## Project Overview

This project demonstrates a **complete DevOps and GitOps workflow** by provisioning a **5-tier VProfile application stack** on a **3-node Kubernetes cluster**. The project emphasizes:
<img width="1024" height="1024" alt="Gemini_Generated_Image_2dw8ll2dw8ll2dw8" src="https://github.com/user-attachments/assets/bb4a2bd7-0202-4859-a606-70f4fd5e0711" />

- **Infrastructure as Code (IaC)** using Ansible and Vagrant  
- **Continuous Integration (CI)** using Jenkins  
- **Continuous Delivery (CD) & GitOps** using ArgoCD  
- **Containerization and orchestration** with Docker and Kubernetes  
- **Monitoring, logging, and security best practices**

The 5-tier application simulates a realistic microservices architecture:

1. **Database Tier:** MySQL/PostgreSQL  
2. **Cache Tier:** Memcached  
3. **Message Broker Tier:** RabbitMQ  
4. **Application Tier:** Tomcat backend  
5. **Web Gateway Tier:** Nginx frontend with HTTPS  

All components are fully automated and integrated, providing a real-world deployment scenario for DevOps and Cloud practices.

> **Note:** Images/screenshots can be added in the `images/` folder to illustrate architecture, dashboards, and deployment flow. For example: `images/cluster-architecture.png`, `images/jenkins-pipeline.png`, `images/argo-sync.png`.

---

## Project Objectives

- Fully automated **Kubernetes cluster provisioning** using Ansible  
- CI/CD pipeline for building Docker images, pushing to **AWS ECR**, and updating the GitOps repo  
- GitOps-based continuous delivery with **ArgoCD**  
- End-to-end automation of 5-tier microservices deployment  
- Secure containerization and service-to-service networking  
- Monitoring and observability using **Prometheus** and **Grafana**  

---

## Detailed Workflow & What Happens Step by Step

1. **Infrastructure Provisioning (Ansible + Vagrant / AWS EC2):**  
   - All nodes are provisioned automatically using Ansible playbooks (`main.yml` and `provision-ec2-3node.yml`)  
   - Roles for `k8s_master` and `k8s_worker` configure Kubernetes control plane and join worker nodes  
   - Container runtime (Docker/Containerd) installed, networking configured, swap disabled  
   - Optional AWS EC2 setup: EC2 instances are provisioned with static private IPs and security groups  

2. **Cluster Initialization:**  
   - Master node is initialized with `kubeadm init`  
   - Worker nodes automatically join the cluster using `kubeadm join`  
   - Cluster networking is configured (Pod network, node-to-node communication)  

3. **Jenkins CI Pipeline:**  
   - **Checkout Code:** Jenkins clones the Graduation-Project repository from GitHub  
   - **Clean Old Docker Images:** Removes any outdated Docker images to avoid conflicts  
   - **Build Docker Image:** Builds multi-stage Docker images for backend and frontend using the `Dockerfile` in `tom-app`  
   - **Login to AWS ECR:** Authenticates Jenkins with ECR credentials  
   - **Push Docker Image to ECR:** Latest Docker images pushed to AWS ECR for GitOps deployment  
   - **Update GitOps Repo:** Jenkins updates the image tags in `vprofile-gitops` directory to trigger ArgoCD sync  

4. **ArgoCD GitOps Deployment:**  
   - ArgoCD installed and configured via Ansible role (`roles/argocd`)  
   - ArgoCD monitors the `vprofile-gitops` repository inside Kubernetes  
   - Automatically detects changes in manifests or image tags and syncs the cluster  
   - Updates pods, services, and ingress rules **without manual kubectl commands**  

5. **Service Communication & Security:**  
   - NetworkPolicy restricts access between tiers; only ingress controller can reach backend services  
   - Secrets and credentials are stored in Kubernetes Secrets  
   - Containers run as non-root, minimal images with multi-stage Dockerfiles  
   - Nginx reverse proxy enforces HTTPS for external access  

6. **Monitoring & Observability:**  
   - Prometheus collects metrics from all nodes, pods, and services  
   - Grafana dashboards visualize:
     - Node CPU & Memory  
     - Pod CPU & Memory  
     - Application availability (HTTP check)  
   - Setup automated via Ansible role `prometheus_stack`  

7. **Automation Highlight:**  
   - **Everything is automated via Ansible playbooks:** cluster setup, Jenkins installation, ArgoCD installation, application deployment, monitoring stack setup  
   - Manual steps are minimized to provisioning EC2 nodes or running playbooks  
<img width="1366" height="661" alt="Screenshot (737)" src="https://github.com/user-attachments/assets/9f530919-9f8d-48b9-ae2f-ff4764235e56" />
<img width="1366" height="641" alt="Screenshot (747)" src="https://github.com/user-attachments/assets/72438b02-79e8-4cd5-b238-82e0f5700049" />

> **Workflow Diagram Suggestion:** Add a visual diagram in `images/workflow-diagram.png` showing CI/CD + GitOps flow, cluster nodes, and 5-tier services  
<img width="1366" height="660" alt="Screenshot (748)" src="https://github.com/user-attachments/assets/1b7b2617-0c4c-45d0-8be8-3f77e145b0b4" />

---
<img width="1366" height="670" alt="Screenshot (738)" src="https://github.com/user-attachments/assets/fa9fe738-19a9-4d03-be28-0a74f9075f53" />
<img width="1366" height="713" alt="Screenshot (739)" src="https://github.com/user-attachments/assets/47c5da87-07a3-42c3-be4f-23f063db350b" />
<img width="1366" height="768" alt="Screenshot (743)" src="https://github.com/user-attachments/assets/9055fe10-d489-4216-b0f2-7bec0cee1a17" />

## Folder Structure

```text
Ohio-Project/
├── ansible-k8s-project/
│   ├── ansible.cfg
│   ├── group_vars/all.yml
│   ├── inventory.ini
│   ├── main.yml
│   ├── Ohio-key.pem
│   └── roles/
│       ├── argocd/tasks/main.yml
│       ├── jenkins/tasks/main.yml
│       ├── jenkins/templates/jenkins-deployment.yml.j2
│       ├── jenkins/templates/jenkins-service.yml.j2
│       ├── k8s_common/tasks/main.yml
│       ├── k8s_master/tasks/main.yml
│       ├── k8s_worker/tasks/main.yml
│       └── prometheus_stack/tasks/main.yml
├── Graduation-Project/
│   ├── db/
│   │   ├── db_backup.sql
│   │   └── Dockerfile
│   ├── docker-compose.yml
│   ├── Jenkinsfile
│   ├── k8s/
│   │   ├── argocd-vprofile.sh
│   │   ├── deployment.yaml
│   │   ├── ingress.yaml
│   │   ├── namespace.yaml
│   │   ├── service.yaml
│   │   └── vprofile-gitops/
│   │       ├── backend/
│   │       │   ├── backend/deployment.yaml
│   │       │   ├── backend/service.yaml
│   │       │   └── backend-ingress/backend-ingress.yaml
│   │       ├── database/
│   │       │   ├── deployment.yaml
│   │       │   ├── pvc.yaml
│   │       │   ├── pv.yaml
│   │       │   ├── secrets.yaml
│   │       │   └── service.yaml
│   │       ├── frontend/
│   │       │   ├── frontend/deployment.yaml
│   │       │   ├── frontend/service.yaml
│   │       │   └── frontend-ingress/frontend-ingress.yaml
│   │       ├── memcached/
│   │       │   ├── deployment.yaml
│   │       │   └── service.yaml
│   │       ├── namespace.yaml
│   │       └── rabbitmq/
│   │           ├── deployment.yaml
│   │           └── service.yaml
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── generate-ssl.sh
│   │   └── vp-app.conf
│   └── tom-app/
│       ├── application.properties
│       └── Dockerfile
└── provisioning-eks-cluster/
    ├── provision-ec2.yml
    └── provision-ec2-3node.yml
````

---

## Running the Project

1. **Provision EC2 / Vagrant Nodes:**

```bash
cd provisioning-eks-cluster
ansible-playbook -i inventory.ini provision-ec2-3node.yml
```

2. **Run Ansible Playbook for Cluster & Services:**

```bash
cd ansible-k8s-project
ansible-playbook -i inventory.ini main.yml
```
![WhatsApp Image 2025-12-01 at 18 37 31_aa106198](https://github.com/user-attachments/assets/94ce50ed-a80c-4cba-9810-11b9cdbfd06a)


3. **Trigger Jenkins Pipeline:**

   * Builds Docker images, pushes to AWS ECR, updates GitOps repo.
<img width="1366" height="641" alt="Screenshot (747)" src="https://github.com/user-attachments/assets/bba88372-6320-4c63-a75e-58f81be08ab2" />
<img width="1366" height="660" alt="Screenshot (748)" src="https://github.com/user-attachments/assets/3cfcbf5a-377d-42c7-843d-a0222999fbb3" />

<img width="1366" height="693" alt="Screenshot (759)" src="https://github.com/user-attachments/assets/06538493-94d8-4a22-affb-c4268b6fc5af" />

4. **Automatic Deployment via ArgoCD:**

   * ArgoCD detects GitOps repo changes and updates Kubernetes deployments.

> Add screenshots to `images/` folder to illustrate each stage: Jenkins build, ECR push, ArgoCD sync, pod rollout, Grafana dashboards.
<img width="1366" height="697" alt="Screenshot (762)" src="https://github.com/user-attachments/assets/d3a1bf85-6566-4731-9380-c30b9b7e817f" />

---

## Security & Best Practices

* Containers run as **non-root** users
* **Multi-stage Dockerfiles** for minimal image size
* Sensitive data in **Kubernetes secrets**
* **NetworkPolicy** restricts traffic between tiers
* HTTPS enforced at Nginx reverse proxy

---

## Monitoring

* Prometheus scrapes metrics from all nodes, pods, and services
* Grafana dashboards visualize:

  * Node CPU & Memory
  * Pod CPU & Memory
  * Application availability (HTTP check)

---

## Author

**Ali Wazeer** – [GitHub](https://github.com/Uliwazeer)

---
<img width="1366" height="694" alt="Screenshot (757)" src="https://github.com/user-attachments/assets/e108e09d-1d0a-4d3f-91fd-b7208074b67e" />
<img width="1366" height="668" alt="Screenshot (756)" src="https://github.com/user-attachments/assets/d3c2ec06-7c73-4ac4-a450-dc88ca6af316" />
<img width="1366" height="768" alt="Screenshot (755)" src="https://github.com/user-attachments/assets/c2ddb8a2-868d-4b44-ae23-73c36de0735f" />
<img width="1366" height="768" alt="Screenshot (754)" src="https://github.com/user-attachments/assets/d4153cf9-4f9e-4c39-bbf6-069d20103b5e" />
<img width="1366" height="768" alt="Screenshot (753)" src="https://github.com/user-attachments/assets/8306252b-7468-4ac8-afcc-8a02d6f0fb3e" />
<img width="1366" height="768" alt="Screenshot (752)" src="https://github.com/user-attachments/assets/be0926a4-5d77-4628-a497-627af20ad25f" />
<img width="1366" height="683" alt="Screenshot (751)" src="https://github.com/user-attachments/assets/360fd449-1d2f-41e6-a006-5111c6af54d7" />
<img width="1366" height="685" alt="Screenshot (750)" src="https://github.com/user-attachments/assets/5c6de39b-027b-4e05-9c11-4e183b03d462" />
<img width="1366" height="701" alt="Screenshot (746)" src="https://github.com/user-attachments/assets/b4789e15-0652-45a6-80de-0462463ad22a" />
<img width="1366" height="693" alt="Screenshot (745)" src="https://github.com/user-attachments/assets/7b5a908d-db8a-40c8-a5f5-423f223f22e1" />
<img width="1366" height="689" alt="Screenshot (744)" src="https://github.com/user-attachments/assets/f687d7d7-49cd-446a-b4a1-8f6d6664d611" />
<img width="1366" height="693" alt="Screenshot (759)" src="https://github.com/user-attachments/assets/11cfb542-8dc6-4291-8ee1-bb677f3d2c8b" />
<img width="1366" height="693" alt="Screenshot (758)" src="https://github.com/user-attachments/assets/98b8bb94-379d-4a09-a9a4-844b7b026b64" />
<img width="1366" height="704" alt="Screenshot (733)" src="https://github.com/user-attachments/assets/84fa9ec4-a8dc-4b2f-9556-1870aa8650a8" />
<img width="1366" height="768" alt="Screenshot (732)" src="https://github.com/user-attachments/assets/55091c5a-540e-4ec7-b113-890660153e0f" />
<img width="1366" height="713" alt="Screenshot (731)" src="https://github.com/user-attachments/assets/40dd73d0-f905-4c01-a5da-5ff9fa1a46f7" />
<img width="1366" height="708" alt="Screenshot (730)" src="https://github.com/user-attachments/assets/90f73057-c2bf-4291-ae8e-8d02ea3913be" />
<img width="1366" height="721" alt="Screenshot (729)" src="https://github.com/user-attachments/assets/64d95af4-36a6-4d97-b7b6-9544be98765e" />
<img width="1366" height="717" alt="Screenshot (728)" src="https://github.com/user-attachments/assets/7a1f7696-3899-4975-bc4a-91388f4a8487" />
<img width="1366" height="721" alt="Screenshot (727)" src="https://github.com/user-attachments/assets/8cd6c7ce-c365-4d50-8651-4aa9e4172290" />
<img width="1366" height="713" alt="Screenshot (726)" src="https://github.com/user-attachments/assets/a102768a-24c0-4bed-a42d-99c42dbd6cdb" />
<img width="1366" height="168" alt="Screenshot (725)" src="https://github.com/user-attachments/assets/28a97f0b-4a4c-4f1f-95da-68f2a71fb609" />
<img width="1366" height="725" alt="Screenshot (724)" src="https://github.com/user-attachments/assets/1417388d-dcc8-4991-8ca2-6a1423f98f70" />
<img width="1366" height="314" alt="Screenshot (722)" src="https://github.com/user-attachments/assets/9736f404-9177-4223-a219-e0ab3b90a65f" />
<img width="1366" height="717" alt="Screenshot (720)" src="https://github.com/user-attachments/assets/5d0f3638-2aca-492f-b03e-e42886396341" />
<img width="1366" height="713" alt="Screenshot (719)" src="https://github.com/user-attachments/assets/fe3da859-99d6-44dc-a841-c71d06d10f9c" />
<img width="1366" height="475" alt="Screenshot (734)" src="https://github.com/user-attachments/assets/f2c24d6e-4cf0-47d4-8193-b56b085bd4bb" />


<img width="1366" height="713" alt="Screenshot (708)" src="https://github.com/user-attachments/assets/7b85a875-d524-44e7-a9c7-0531a7cab0ec" />
<img width="1366" height="713" alt="Screenshot (707)" src="https://github.com/user-attachments/assets/5d922082-346a-4de6-9134-864345f4ffdc" />
<img width="1366" height="717" alt="Screenshot (706)" src="https://github.com/user-attachments/assets/34a8d191-db3a-4384-aab7-20a870730fa3" />
<img width="1366" height="683" alt="Screenshot (705)" src="https://github.com/user-attachments/assets/7d4aeca3-a035-457a-8487-4553f911ab6d" />
<img width="1366" height="704" alt="Screenshot (703)" src="https://github.com/user-attachments/assets/afb41240-41b2-470c-88e9-8427b38bcbe9" />
<img width="1366" height="644" alt="Screenshot (702)" src="https://github.com/user-attachments/assets/f4ed86bc-9207-42f5-a20b-1da080f50e38" />
<img width="1366" height="678" alt="Screenshot (701)" src="https://github.com/user-attachments/assets/dab57e2f-6351-4c18-b365-b7a20fed2da1" />
<img width="1366" height="768" alt="Screenshot (700)" src="https://github.com/user-attachments/assets/acab2202-2538-4c00-894b-132feb8312aa" />
<img width="1366" height="366" alt="Screenshot (699)" src="https://github.com/user-attachments/assets/62f4b53d-5dfa-4052-b3e3-f64abf925ed7" />
<img width="1366" height="721" alt="Screenshot (697)" src="https://github.com/user-attachments/assets/7aef3a22-f9d0-4d86-96da-032873eb345a" />
<img width="1366" height="717" alt="Screenshot (696)" src="https://github.com/user-attachments/assets/a9a59927-4fe7-4d91-a8d9-247b3139eb2e" />
<img width="1366" height="713" alt="Screenshot (718)" src="https://github.com/user-attachments/assets/dac57477-2fce-412f-8f2c-c2b6a1218441" />
<img width="1366" height="713" alt="Screenshot (717)" src="https://github.com/user-attachments/assets/90ab221e-9de2-450a-965a-89283ce0919f" />
<img width="1366" height="721" alt="Screenshot (716)" src="https://github.com/user-attachments/assets/661a4a11-d306-48f6-9a85-d8911a63ce38" />
<img width="1366" height="713" alt="Screenshot (715)" src="https://github.com/user-attachments/assets/d40c2b71-4f56-4d90-bdaf-529da0d92429" />
<img width="1366" height="721" alt="Screenshot (714)" src="https://github.com/user-attachments/assets/bb25028e-d756-4734-b8b2-d723f05d1041" />
<img width="1366" height="717" alt="Screenshot (713)" src="https://github.com/user-attachments/assets/ae7272ea-e1ba-469d-b038-6baf24c34afa" />
<img width="1366" height="708" alt="Screenshot (712)" src="https://github.com/user-attachments/assets/7b47851b-2536-488f-a680-90b034ae3429" />
<img width="1366" height="708" alt="Screenshot (710)" src="https://github.com/user-attachments/assets/2d2ef886-6464-4e31-a7a1-db9609932807" />
<img width="1366" height="708" alt="Screenshot (709)" src="https://github.com/user-attachments/assets/e81453c3-337c-41a8-b536-66b4eb0882af" />

![WhatsApp Image 2025-12-01 at 18 37 31_a2c08f7b](https://github.com/user-attachments/assets/221680df-d7be-4886-b971-ce1be30653b5)
![WhatsApp Image 2025-12-01 at 18 37 31_88208d88](https://github.com/user-attachments/assets/0e7a4271-1e4d-4b9f-978d-603eefd3493e)
![WhatsApp Image 2025-12-01 at 18 37 31_06999bef](https://github.com/user-attachments/assets/715ee02f-08aa-433d-a726-dc49525a85bf)
![WhatsApp Image 2025-12-01 at 18 37 31_2a58ae19](https://github.com/user-attachments/assets/c7d8425b-5467-4c36-8b5c-bba835305dc3)
<img width="1366" height="649" alt="Screenshot (765)" src="https://github.com/user-attachments/assets/6781113e-9e76-4d49-a0ef-8df2f95f8596" />
<img width="1366" height="721" alt="Screenshot (764)" src="https://github.com/user-attachments/assets/e6e1c839-15e0-4333-b3a6-3a7ebc8e4c5c" />
<img width="1366" height="725" alt="Screenshot (763)" src="https://github.com/user-attachments/assets/3d1a21e7-e7da-4446-93a1-4eb3bdf623e0" />
<img width="1366" height="327" alt="Screenshot (761)" src="https://github.com/user-attachments/assets/447a4363-b80a-48e5-a325-c7d9d8a39d9c" />
<img width="1366" height="717" alt="Screenshot (760)" src="https://github.com/user-attachments/assets/7c6dafa8-6a9a-4250-b21b-291aa0f352b9" />
![WhatsApp Image 2025-12-01 at 18 37 32_d8e9ad24](https://github.com/user-attachments/assets/8d2c9741-c501-4906-90a4-bf84167f689b)
![WhatsApp Image 2025-12-01 at 18 37 32_3cbf4a61](https://github.com/user-attachments/assets/901edcec-1bcc-40d7-afe1-63cb8f427d98)
![WhatsApp Image 2025-12-01 at 18 37 32_1b496c2d](https://github.com/user-attachments/assets/837fe3bc-022f-4a16-951c-8792c7a82560)

```
