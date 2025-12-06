Ansible project for 2-node Kubernetes cluster (master + worker)

Steps:
1. Run: ansible-playbook -i inventory.ini main.yml
2. This will:
   - Install Docker and kube packages
   - Init master
   - Join worker
   - Install Jenkins, ArgoCD, Prometheus stack (placeholders)
