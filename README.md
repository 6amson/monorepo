## N:B: As of when this READ.ME was updated, the resources that powers this flow has been suspended to avoid incurring compute bills. To visualize a successful deployment, check the commits for those with successful deployments and consider the logs.

# EKS Deployment Workflow
1. Introduction This document outlines the setup and workflow for deploying a containerized application on Amazon Elastic Kubernetes Service (EKS). The solution demonstrates infrastructure automation, application deployment, and scalability.

2. Objectives
Deploy a containerized application using EKS.
Automate build and deployment using GitHub Actions.
Ensure high availability and scalability.

3. Infrastructure Overview
Components:
Amazon EKS Cluster: Provisioned with Kubernetes control plane.
Elastic Load Balancer: Routes traffic to the application.
ECR (Elastic Container Registry): Stores container images.
Cluster Details:
Cluster Name: thisEKS
ECR Repository: monorepo

4. Deployment Workflow
Step 1: EKS Cluster Setup
Created an EKS cluster (thisEKS) with managed nodes but no node group.
VPC and its subnets were configured. 
Configured IAM roles and security groups for access control.
Step 2: Application Configuration
Application code resides in the monorepo directory.
Dockerized the application using a Dockerfile.
Pushed application to Github to trigger the workflow.
Step 3: CI/CD Workflow with GitHub Actions
Workflow Steps:
Build: Build the Docker image for the application.
Push: Push the image to ECR.
Deploy: Deploy the updated image to EKS.
Sample GitHub Workflow File (.github/workflows/deploy.yml)
name: Deploy to Amazon EKS


on:
  push:
    branches: ['main', 'master']


env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: monorepo
  EKS_CLUSTER: thisEKS
  K8S_DIRECTORY: k8s/


permissions:
  contents: read


jobs:
  deploy:
    name: Deploy
    runs-on: ubuntu-latest
    environment: production


    steps:
      - name: Checkout
        uses: actions/checkout@v4


      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}


      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1


      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT


      # Kubernetes (EKS) Deployment
      - name: Update kube config
        run: aws eks update-kubeconfig --name ${{ env.EKS_CLUSTER }} --region ${{ env.AWS_REGION }}


      # Update the image in deployment file
      - name: Update deployment image
        run: |
          # Assuming your deployment.yaml has an image placeholder
          sed -i "s|image:.*|image: ${{ steps.build-image.outputs.image }}|" ${{ env.K8S_DIRECTORY }}/deployment.yaml


      - name: Deploy to Kubernetes (EKS)
        run: |
          kubectl apply -f ${{ env.K8S_DIRECTORY }}/deployment.yaml
          kubectl apply -f ${{ env.K8S_DIRECTORY }}/service.yaml
          kubectl rollout status deployment/monorepo






Step 4: Kubernetes Resources
Deployment: Defined to ensure multiple replicas of the application pod; config file is found in the k8s directory named: deployment.yaml.
Service: Exposed as a LoadBalancer for external access; config file is found in the k8s directory named: service.yaml.

Challenges Faced and Solutions
Pod Scheduling Issues:


Solution: Ensured sufficient node capacity and resource limits.
Load Balancer Pending State:


Solution: Verified security group rules and node IAM roles.
Image Pull Issues:


Solution: Corrected ECR image path and ensured proper login.

Best Practices Followed
Used managed node groups for scaling and maintenance.
Ensured infrastructure-as-code through reusable GitHub workflows.
Secured ECR access with IAM roles.
Followed containerization principles for portability.


 Conclusion
This deployment architecture using EKS demonstrated an automated, scalable, and secure approach to deploying containerized applications. By leveraging Kubernetes’ orchestration capabilities and GitHub Actions for CI/CD.
Potential Next Steps:
Enhance monitoring and alerting.
Implement additional security best practices.
Explore blue-green deployments for zero-downtime updates.
Attach and configure node groups for compute capacity.
