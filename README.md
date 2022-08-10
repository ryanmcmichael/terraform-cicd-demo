# Terraform EKS CI/CD Demo

As the vast majority of my client work remains under NDA, I've put together a simple demonstration of a generalized infrastructure-as-code implementation of a secure, scalable, and resilient containerized 3-tier web app. This one uses GitHub Actions to build the code and continuously deploy to an AWS Elastic Kubernetes Service cluster. The system has a Multi-AZ RDS backend. Logging and metrics are ingested and displayed via CloudWatch. 
