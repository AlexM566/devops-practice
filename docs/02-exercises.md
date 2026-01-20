# Exercise Index

This document provides a complete index of all available exercises in the DevOps Interview Playground, organized by technology domain. Each exercise includes difficulty level, estimated completion time, and a brief description.

## Table of Contents

- [Docker Exercises](#docker-exercises)
- [Kubernetes Exercises](#kubernetes-exercises)
- [Linux Administration Exercises](#linux-administration-exercises)
- [Networking Exercises](#networking-exercises)
- [Terraform Exercises](#terraform-exercises)
- [Python Exercises](#python-exercises)
- [CI/CD Exercises](#cicd-exercises)
- [Suggested Learning Paths](#suggested-learning-paths)

## Docker Exercises

### Beginner Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Docker Basics](../exercises/docker/docker-basics.md) | Beginner | 20 min | Learn to run containers, execute commands, and view logs |
| [Docker Images](../exercises/docker/docker-images.md) | Beginner | 25 min | Build custom images, tag them, and understand image layers |
| [Docker Volumes](../exercises/docker/docker-volumes.md) | Beginner | 20 min | Create and manage volumes for data persistence |

### Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Docker Networking](../exercises/docker/docker-networking.md) | Intermediate | 30 min | Create custom networks and connect containers |
| [Docker Compose Basics](../exercises/docker/docker-compose-basics.md) | Intermediate | 35 min | Write docker-compose files for multi-service applications |

**Total Docker Exercises**: 5 (3 beginner, 2 intermediate)  
**Total Estimated Time**: 2 hours 10 minutes

## Kubernetes Exercises

### Beginner Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Kubernetes Pods](../exercises/kubernetes/k8s-pods.md) | Beginner | 25 min | Create pods, view logs, and execute commands in containers |
| [Kubernetes Deployments](../exercises/kubernetes/k8s-deployments.md) | Beginner | 30 min | Create deployments, scale applications, and perform rolling updates |
| [Kubernetes Services](../exercises/kubernetes/k8s-services.md) | Beginner | 25 min | Expose applications with services and test service discovery |

### Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Kubernetes ConfigMaps & Secrets](../exercises/kubernetes/k8s-config.md) | Intermediate | 30 min | Manage application configuration and sensitive data |
| [Kubernetes Storage](../exercises/kubernetes/k8s-storage.md) | Intermediate | 35 min | Work with PersistentVolumes and PersistentVolumeClaims |

**Total Kubernetes Exercises**: 5 (3 beginner, 2 intermediate)  
**Total Estimated Time**: 2 hours 25 minutes

## Linux Administration Exercises

### Beginner Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Linux Files & Permissions](../exercises/linux/linux-files.md) | Beginner | 20 min | Master file operations, permissions, and ownership |
| [Linux Processes](../exercises/linux/linux-processes.md) | Beginner | 20 min | View, manage, and control processes |
| [Linux Users & Groups](../exercises/linux/linux-users.md) | Beginner | 25 min | Create users, manage groups, and configure sudo access |

### Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Linux Scripting](../exercises/linux/linux-scripting.md) | Intermediate | 40 min | Write bash scripts with variables, loops, and conditionals |
| [Linux Package Management](../exercises/linux/linux-packages.md) | Intermediate | 30 min | Install packages, update systems, and manage services |

**Total Linux Exercises**: 5 (3 beginner, 2 intermediate)  
**Total Estimated Time**: 2 hours 15 minutes

## Networking Exercises

### Beginner Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Network Basics](../exercises/networking/network-basics.md) | Beginner | 20 min | Use ping and curl to test connectivity |
| [DNS Resolution](../exercises/networking/network-dns.md) | Beginner | 20 min | Use dig and nslookup to resolve hostnames |
| [Network Ports](../exercises/networking/network-ports.md) | Beginner | 20 min | Check listening ports and test port connectivity |

### Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Network Troubleshooting](../exercises/networking/network-troubleshooting.md) | Intermediate | 35 min | Debug connectivity issues and trace network routes |
| [Docker Networking](../exercises/networking/network-docker.md) | Intermediate | 30 min | Understand Docker networks, bridge vs host mode, and isolation |

**Total Networking Exercises**: 5 (3 beginner, 2 intermediate)  
**Total Estimated Time**: 2 hours 5 minutes

## Terraform Exercises

### Beginner/Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Terraform Basics](../exercises/terraform/terraform-basics.md) | Beginner | 30 min | Write basic configurations and use terraform init/plan/apply |
| [Terraform Variables](../exercises/terraform/terraform-variables.md) | Intermediate | 30 min | Use variables, outputs, and locals in configurations |
| [Terraform Modules](../exercises/terraform/terraform-modules.md) | Intermediate | 40 min | Create and use modules for reusable infrastructure code |

**Total Terraform Exercises**: 3 (1 beginner, 2 intermediate)  
**Total Estimated Time**: 1 hour 40 minutes

## Python Exercises

Python exercises use the dedicated `devops-python` container with pre-installed DevOps libraries.

**Access the Python container:**
```bash
docker exec -it devops-python bash
```

### Beginner Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Python Variables](../exercises/python/python-basics-variables.md) | Beginner | 20 min | Variables, data types, and basic operations |
| [Python Control Flow](../exercises/python/python-basics-control-flow.md) | Beginner | 25 min | If/else statements, loops (for, while) |
| [Python Functions](../exercises/python/python-basics-functions.md) | Beginner | 25 min | Functions, parameters, return values |
| [Python Error Handling](../exercises/python/python-basics-error-handling.md) | Beginner | 25 min | Try/except, raising exceptions |
| [Python Objects](../exercises/python/python-basics-objects.md) | Beginner | 30 min | Classes, objects, methods |

### Intermediate Level

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [API Requests](../exercises/python/python-api-requests.md) | Intermediate | 30 min | Make HTTP requests to playground services |
| [YAML Parsing](../exercises/python/python-yaml-parsing.md) | Intermediate | 25 min | Parse and modify YAML configuration files |
| [Log Analysis](../exercises/python/python-log-analysis.md) | Intermediate | 30 min | Parse and analyze log files |
| [Automation Scripts](../exercises/python/python-automation.md) | Intermediate | 35 min | Write automation script for service health checks |
| [Config Management](../exercises/python/python-config-management.md) | Intermediate | 30 min | Generate configuration files using Jinja2 templates |

**Total Python Exercises**: 10 (5 beginner, 5 intermediate)  
**Total Estimated Time**: 4 hours 35 minutes

## CI/CD Exercises

CI/CD exercises use the `devops-cicd` simulator container to validate and run pipelines locally.

**Access the CI/CD simulator:**
```bash
docker exec -it devops-cicd bash

# Validate a workflow
python -m simulator.cli validate workflow.yml --type github

# Run a workflow
python -m simulator.cli run workflow.yml --type github
```

### GitHub Actions

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [GitHub Actions Basics](../exercises/cicd/github-actions-basics.md) | Beginner | 30 min | Create basic workflow with build and test jobs |
| [GitHub Actions Matrix](../exercises/cicd/github-actions-matrix.md) | Intermediate | 35 min | Create workflow with matrix strategy |
| [GitHub Actions Artifacts](../exercises/cicd/github-actions-artifacts.md) | Intermediate | 30 min | Create workflow that produces and uses artifacts |

### Azure Pipelines

| Exercise | Difficulty | Time | Description |
|----------|-----------|------|-------------|
| [Azure Pipelines Basics](../exercises/cicd/azure-pipelines-basics.md) | Beginner | 30 min | Create basic pipeline with stages and jobs |
| [Azure Pipelines Stages](../exercises/cicd/azure-pipelines-stages.md) | Intermediate | 35 min | Create multi-stage pipeline with dependencies |

**Total CI/CD Exercises**: 5 (2 beginner, 3 intermediate)  
**Total Estimated Time**: 2 hours 40 minutes

## Summary Statistics

| Domain | Total Exercises | Beginner | Intermediate | Total Time |
|--------|----------------|----------|--------------|------------|
| Docker | 5 | 3 | 2 | 2h 10m |
| Kubernetes | 5 | 3 | 2 | 2h 25m |
| Linux | 5 | 3 | 2 | 2h 15m |
| Networking | 5 | 3 | 2 | 2h 5m |
| Terraform | 3 | 1 | 2 | 1h 40m |
| Python | 10 | 5 | 5 | 4h 35m |
| CI/CD | 5 | 2 | 3 | 2h 40m |
| **Total** | **38** | **20** | **18** | **17h 50m** |

## Suggested Learning Paths

### Path 1: Complete Beginner (Start Here!)

If you're new to DevOps, follow this path to build foundational skills:

1. **Linux Basics** (1h 5m)
   - [Linux Files & Permissions](../exercises/linux/linux-files.md)
   - [Linux Processes](../exercises/linux/linux-processes.md)
   - [Linux Users & Groups](../exercises/linux/linux-users.md)

2. **Networking Fundamentals** (1h)
   - [Network Basics](../exercises/networking/network-basics.md)
   - [DNS Resolution](../exercises/networking/network-dns.md)
   - [Network Ports](../exercises/networking/network-ports.md)

3. **Docker Fundamentals** (1h 5m)
   - [Docker Basics](../exercises/docker/docker-basics.md)
   - [Docker Images](../exercises/docker/docker-images.md)
   - [Docker Volumes](../exercises/docker/docker-volumes.md)

4. **Kubernetes Basics** (1h 20m)
   - [Kubernetes Pods](../exercises/kubernetes/k8s-pods.md)
   - [Kubernetes Deployments](../exercises/kubernetes/k8s-deployments.md)
   - [Kubernetes Services](../exercises/kubernetes/k8s-services.md)

**Total Time**: ~4.5 hours

### Path 2: Container Specialist

Focus on containerization and orchestration:

1. **Docker Deep Dive** (2h 10m)
   - Complete all Docker exercises in order
   - [Docker Basics](../exercises/docker/docker-basics.md)
   - [Docker Images](../exercises/docker/docker-images.md)
   - [Docker Volumes](../exercises/docker/docker-volumes.md)
   - [Docker Networking](../exercises/docker/docker-networking.md)
   - [Docker Compose Basics](../exercises/docker/docker-compose-basics.md)

2. **Kubernetes Mastery** (2h 25m)
   - Complete all Kubernetes exercises in order
   - [Kubernetes Pods](../exercises/kubernetes/k8s-pods.md)
   - [Kubernetes Deployments](../exercises/kubernetes/k8s-deployments.md)
   - [Kubernetes Services](../exercises/kubernetes/k8s-services.md)
   - [Kubernetes ConfigMaps & Secrets](../exercises/kubernetes/k8s-config.md)
   - [Kubernetes Storage](../exercises/kubernetes/k8s-storage.md)

3. **Container Networking** (30m)
   - [Docker Networking](../exercises/networking/network-docker.md)

**Total Time**: ~5 hours

### Path 3: Infrastructure as Code

Focus on automation and infrastructure management:

1. **Linux Administration** (2h 15m)
   - Complete all Linux exercises
   - [Linux Files & Permissions](../exercises/linux/linux-files.md)
   - [Linux Processes](../exercises/linux/linux-processes.md)
   - [Linux Users & Groups](../exercises/linux/linux-users.md)
   - [Linux Scripting](../exercises/linux/linux-scripting.md)
   - [Linux Package Management](../exercises/linux/linux-packages.md)

2. **Terraform** (1h 40m)
   - Complete all Terraform exercises
   - [Terraform Basics](../exercises/terraform/terraform-basics.md)
   - [Terraform Variables](../exercises/terraform/terraform-variables.md)
   - [Terraform Modules](../exercises/terraform/terraform-modules.md)

3. **Docker Compose** (35m)
   - [Docker Compose Basics](../exercises/docker/docker-compose-basics.md)

**Total Time**: ~4.5 hours

### Path 4: Python DevOps Automation

Focus on Python scripting for DevOps tasks:

1. **Python Fundamentals** (2h 5m)
   - [Python Variables](../exercises/python/python-basics-variables.md)
   - [Python Control Flow](../exercises/python/python-basics-control-flow.md)
   - [Python Functions](../exercises/python/python-basics-functions.md)
   - [Python Error Handling](../exercises/python/python-basics-error-handling.md)
   - [Python Objects](../exercises/python/python-basics-objects.md)

2. **DevOps Automation** (2h 30m)
   - [API Requests](../exercises/python/python-api-requests.md)
   - [YAML Parsing](../exercises/python/python-yaml-parsing.md)
   - [Log Analysis](../exercises/python/python-log-analysis.md)
   - [Automation Scripts](../exercises/python/python-automation.md)
   - [Config Management](../exercises/python/python-config-management.md)

**Total Time**: ~4.5 hours

### Path 5: CI/CD Pipeline Development

Focus on writing CI/CD pipelines:

1. **GitHub Actions** (1h 35m)
   - [GitHub Actions Basics](../exercises/cicd/github-actions-basics.md)
   - [GitHub Actions Matrix](../exercises/cicd/github-actions-matrix.md)
   - [GitHub Actions Artifacts](../exercises/cicd/github-actions-artifacts.md)

2. **Azure Pipelines** (1h 5m)
   - [Azure Pipelines Basics](../exercises/cicd/azure-pipelines-basics.md)
   - [Azure Pipelines Stages](../exercises/cicd/azure-pipelines-stages.md)

**Total Time**: ~2.5 hours

### Path 6: Interview Preparation (Comprehensive)

Complete all exercises for comprehensive DevOps knowledge:

**Week 1: Foundations**
- All Linux exercises (2h 15m)
- All Networking exercises (2h 5m)

**Week 2: Containers**
- All Docker exercises (2h 10m)
- All Kubernetes exercises (2h 25m)

**Week 3: Infrastructure as Code & Automation**
- All Terraform exercises (1h 40m)
- All Python exercises (4h 35m)

**Week 4: CI/CD**
- All CI/CD exercises (2h 40m)
- Review and practice troubleshooting

**Total Time**: ~17.5 hours

### Path 7: Quick Interview Prep (Time-Constrained)

If you have limited time before an interview, focus on these high-impact exercises:

1. [Docker Basics](../exercises/docker/docker-basics.md) - 20 min
2. [Docker Compose Basics](../exercises/docker/docker-compose-basics.md) - 35 min
3. [Kubernetes Deployments](../exercises/kubernetes/k8s-deployments.md) - 30 min
4. [Kubernetes Services](../exercises/kubernetes/k8s-services.md) - 25 min
5. [Linux Scripting](../exercises/linux/linux-scripting.md) - 40 min
6. [Network Troubleshooting](../exercises/networking/network-troubleshooting.md) - 35 min
7. [Python API Requests](../exercises/python/python-api-requests.md) - 30 min
8. [GitHub Actions Basics](../exercises/cicd/github-actions-basics.md) - 30 min

**Total Time**: ~4 hours

## Tips for Success

### Before Starting

- Ensure all services are running: `docker-compose ps`
- Verify you can access the web interfaces (Grafana, Prometheus)
- Have the documentation open for reference

### During Exercises

- Read the entire exercise before starting
- Follow instructions step-by-step
- Don't skip verification steps
- Use hints if you get stuck (they're in collapsible sections)
- Compare your output with expected output
- Review the solution only after attempting the exercise

### After Completing Exercises

- Try variations of the exercises
- Combine concepts from different exercises
- Practice troubleshooting by intentionally breaking things
- Document your own notes and learnings
- Share your experience and contribute improvements

## Prerequisites by Exercise

### No Prerequisites
- All "Basics" exercises can be started immediately
- Linux Files & Permissions
- Network Basics
- Docker Basics
- Python Variables
- GitHub Actions Basics
- Azure Pipelines Basics

### Requires Docker Knowledge
- All Kubernetes exercises
- Docker Networking exercises
- Terraform exercises (basic Docker understanding helpful)

### Requires Linux Knowledge
- Linux Scripting
- Linux Package Management
- Advanced networking exercises

### Requires Python Basics
- Python API Requests
- Python YAML Parsing
- Python Log Analysis
- Python Automation
- Python Config Management

### Requires Kubernetes Cluster
- All Kubernetes exercises require the kind cluster to be running
- Run `cd kubernetes && ./setup-k8s.sh` before starting

## Getting Help

If you're stuck on an exercise:

1. Check the **Hints** section (collapsible in each exercise)
2. Review the **Expected Output** to see what success looks like
3. Verify prerequisites are met
4. Check service logs: `docker-compose logs SERVICE_NAME`
5. Review the **Solution** section (try to avoid this until you've attempted the exercise)
6. Check the [README troubleshooting section](README.md#troubleshooting)

## Contributing

Found an issue with an exercise or want to add new ones? See [Contributing Guide](03-contributing.md) for guidelines on contributing to the playground.

## Next Steps

Ready to start? Pick a learning path above or dive into any exercise that interests you. Remember:

- Start with exercises that match your current skill level
- Don't rush - understanding is more important than speed
- Practice makes perfect - repeat exercises if needed
- Have fun and experiment!

Happy learning! 🚀
