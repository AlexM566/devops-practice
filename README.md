# DevOps Interview Playground

A comprehensive Docker Compose-based practice environment for learning and mastering essential DevOps skills. This playground provides hands-on access to real-world tools and services, along with guided exercises to help you prepare for DevOps interviews and improve your technical skills.

## 📚 Documentation

All documentation has been organized in the `docs/` folder:

- **[Documentation Index](docs/00-index.md)** - Start here for navigation
- **[Main README](docs/01-readme.md)** - Full setup guide and service information
- **[Exercise Index](docs/02-exercises.md)** - Complete list of 38 exercises
- **[Contributing Guide](docs/03-contributing.md)** - How to contribute
- **[Testing Guide](docs/04-testing.md)** - Environment validation procedures
- **[Changelog](docs/changelog/changelog.md)** - Version history

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone <repository-url>
cd devops-playground

# 2. Start all services
docker-compose up -d

# 3. Verify services are running
docker-compose ps

# 4. (Optional) Set up Kubernetes cluster for k8s exercises
cd kubernetes && ./setup-k8s.sh && cd ..

# 5. Start learning!
# Browse exercises in the exercises/ directory
```

## 🎯 Features

- **13 Pre-configured Services**: Web apps, databases, monitoring, Python DevOps, CI/CD simulator, and more
- **38 Hands-on Exercises**: Docker, Kubernetes, Linux, Networking, Terraform, Python, CI/CD
- **Python DevOps Service**: Practice Python automation with pre-installed DevOps libraries
- **CI/CD Simulator**: Write and test GitHub Actions and Azure Pipelines locally
- **Exercise Reset**: Restore exercises to initial state with a simple script
- **Kubernetes Cluster**: Local kind cluster for container orchestration
- **Monitoring Stack**: Prometheus, Grafana, and Loki
- **Practice Containers**: Ubuntu and Alpine with DevOps tools
- **One Command Setup**: `docker-compose up` and you're ready

## 📋 Prerequisites

- Docker Desktop (20.10+)
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- WSL 2 (Windows users only)
- kind and kubectl (for Kubernetes exercises)
- Terraform (optional, for Terraform exercises)

See [full prerequisites](docs/01-readme.md#prerequisites) for details.

## 🎓 Learning Paths

### Beginner Path (4.5 hours)
Start with Linux basics, then Docker, then Kubernetes fundamentals.

### Container Specialist (5 hours)
Deep dive into Docker and Kubernetes with networking.

### Infrastructure as Code (4.5 hours)
Focus on Linux administration, Terraform, and automation.

### Interview Prep (10.5 hours)
Complete all 23 exercises for comprehensive DevOps knowledge.

See [detailed learning paths](docs/02-exercises.md#suggested-learning-paths).

## 🌐 Available Services

| Service | Port | Credentials |
|---------|------|-------------|
| Nginx Web | 80 | - |
| Node.js API | 3000 | - |
| PostgreSQL | 5432 | devops / devops123 |
| Redis | 6379 | - |
| Prometheus | 9090 | - |
| Grafana | 3001 | admin / admin123 |
| Loki | 3100 | - |
| Python DevOps | - | (exec into container) |
| CI/CD Simulator | - | (exec into container) |

See [full service list](docs/01-readme.md#available-services) for details.

## 🐍 Python DevOps Service

Practice Python automation with a dedicated container that includes common DevOps libraries.

```bash
# Access the Python container
docker exec -it devops-python bash

# Run Python scripts
python your_script.py

# Run tests
pytest test_solution.py
```

Pre-installed libraries: requests, boto3, pyyaml, jinja2, paramiko, python-dotenv, click, rich, pytest

See [Python exercises](docs/02-exercises.md#python-exercises) for hands-on practice.

## 🔄 CI/CD Simulator

Write and test GitHub Actions and Azure Pipelines locally without external dependencies.

```bash
# Access the CI/CD simulator container
docker exec -it devops-cicd bash

# Validate a GitHub Actions workflow
python -m simulator.cli validate workflow.yml --type github

# Run a GitHub Actions workflow
python -m simulator.cli run workflow.yml --type github

# Run an Azure Pipeline
python -m simulator.cli run pipeline.yml --type azure
```

See [CI/CD exercises](docs/02-exercises.md#cicd-exercises) for hands-on practice.

## 🔄 Reset Exercises

Made changes to exercises and want to start fresh? Use the reset script:

```bash
# List modified exercise files
./scripts/reset-exercises.sh -l

# Reset all exercises to initial state
./scripts/reset-exercises.sh -a

# Reset specific exercise or directory
./scripts/reset-exercises.sh exercises/docker/docker-basics.md
./scripts/reset-exercises.sh exercises/docker/
```

Note: The reset script uses git to restore files. Commit any work you want to keep before resetting.

## 🛠️ Troubleshooting

Common issues and solutions:

- **Docker not running**: Start Docker Desktop
- **Port conflicts**: Check `docker-compose ps` and stop conflicting services
- **Insufficient resources**: Increase Docker Desktop RAM to 8GB+
- **Services unhealthy**: Check logs with `docker-compose logs SERVICE_NAME`

See [full troubleshooting guide](docs/01-readme.md#troubleshooting).

## 🤝 Contributing

We welcome contributions! See the [Contributing Guide](docs/03-contributing.md) for:
- Adding new exercises
- Improving existing content
- Adding new services
- Reporting issues

## 📝 License

This project is provided as-is for educational purposes.

## 🔗 Quick Links

- [Exercise Index](docs/02-exercises.md)
- [Docker Exercises](docs/02-exercises.md#docker-exercises)
- [Kubernetes Exercises](docs/02-exercises.md#kubernetes-exercises)
- [Linux Exercises](docs/02-exercises.md#linux-administration-exercises)
- [Networking Exercises](docs/02-exercises.md#networking-exercises)
- [Terraform Exercises](docs/02-exercises.md#terraform-exercises)
- [Python Exercises](docs/02-exercises.md#python-exercises)
- [CI/CD Exercises](docs/02-exercises.md#cicd-exercises)

---

**Version**: 1.1.0 | **Last Updated**: 2026-01-20 | **Exercises**: 38 | **Services**: 13

