AWS Voting App – EKS, Terraform, ALB Ingress
🚀 Summary
This project deploys a multi-service voting app on AWS using Elastic Kubernetes Service (EKS). It features an advanced, production-grade ingress setup, with all traffic routed through a single AWS Application Load Balancer (ALB) thanks to Kubernetes Ingress and the AWS Load Balancer Controller.

🏗️ What's Inside
Terraform IaC for:

EKS cluster provisioning

OIDC and IAM Role for Service Accounts (IRSA)

ECR repositories for app images

AWS Load Balancer Controller setup

Helm charts for all voting app services (vote, result, worker, redis, postgres)

Kubernetes manifests for:

Scalable Deployments and Services

Ingress resource for unified ALB routing

📦 What You Achieved (Milestones)
EKS cluster bootstrapped using Terraform

ECR registries provisioned for app images

Secure IAM/IRSA integration for K8s Service Accounts

AWS Load Balancer Controller deployed via Helm

App services changed from LoadBalancer to ClusterIP

Key to enabling single ALB Ingress routing

Unified Ingress resource created:

ALB routes / to voting-app-vote (frontend)

ALB routes /results to voting-app-result (backend)

Infrastructure made cloud-native, scalable, and cost-efficient

🌐 How It Works
All user traffic enters via one public AWS ALB

Ingress controller maps URL paths to K8s services

/ → vote frontend (voting-app-vote)

/results → results backend (voting-app-result)

Internal routing uses ClusterIP for efficient service-to-pod mapping

App containers listen securely, and AWS health checks are aligned with service endpoints

🔧 Deployment Steps (Quick Reference)
Deploy EKS, ECR, IAM with Terraform:

```bash
terraform apply
Build & push Docker images to ECR
```
Install Helm charts for all services

```bash
helm upgrade --install voting-app ./aws-voting-app -n default
Apply ClusterIP services & Ingress resources
```
Access your app via the AWS ALB DNS:

http://<alb-dns>/ (Voting UI)

http://<alb-dns>/results (Results API/backend)

🕵️‍♂️ Troubleshooting
502 Bad Gateway from ALB?

Pod isn’t listening on correct port? (should be 0.0.0.0, port matches Service targetPort)

Health check path/port mismatch? Add or adjust Ingress annotations:


alb.ingress.kubernetes.io/healthcheck-path: /results
alb.ingress.kubernetes.io/healthcheck-port: '4000'
Check pod endpoints:

```bash
kubectl get endpoints voting-app-result -n default
kubectl port-forward svc/voting-app-result 8081:4000
curl http://localhost:8081/results
```
AWS EC2 Target Group health? (Console > Target Groups)

Pod and Service labels/selectors must match!

Ingress must reference correct Service port.

📝 Key Files and Directories
terraform/: Full IaC for EKS, IAM, ECR, ALB

k8s/helm/: Helm charts and values.yaml files

k8s/helm/templates/ingress.yaml: Ingress configuration for ALB

README.md: This documentation
