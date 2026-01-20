# Changelog

All notable changes to the DevOps Interview Playground will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-19

### Added

#### Infrastructure
- Docker Compose configuration with 11 services
- Custom bridge networks (frontend, backend, monitoring)
- Named volumes for data persistence
- Resource limits for all containers
- Health checks for critical services

#### Services
- Nginx web server (port 8080)
- Node.js API with health and metrics endpoints (port 3000)
- PostgreSQL database (port 5432)
- Redis cache (port 6379)
- Prometheus monitoring (port 9090)
- Grafana dashboards (port 3001)
- Loki log aggregation (port 3100)
- Promtail log collection
- Ubuntu practice container with DevOps tools
- Alpine practice container for minimal environment

#### Kubernetes
- kind cluster configuration (1 control-plane, 2 workers)
- Automated setup script (setup-k8s.sh)
- Example Kubernetes manifests:
  - Deployment examples
  - Service examples (ClusterIP, NodePort, LoadBalancer)
  - ConfigMap and Secret examples
  - Ingress examples
  - PersistentVolume examples

#### Terraform
- Basic resource creation example
- Variables and outputs example
- Module structure example
- State management example

#### Exercises (23 total)

**Docker Exercises (5)**
- docker-basics.md - Container lifecycle management
- docker-images.md - Building and managing images
- docker-volumes.md - Data persistence
- docker-networking.md - Custom networks and connectivity
- docker-compose-basics.md - Multi-service applications

**Kubernetes Exercises (5)**
- k8s-pods.md - Pod creation and management
- k8s-deployments.md - Deployments and scaling
- k8s-services.md - Service discovery and exposure
- k8s-config.md - ConfigMaps and Secrets
- k8s-storage.md - PersistentVolumes and Claims

**Linux Exercises (5)**
- linux-files.md - File operations and permissions
- linux-processes.md - Process management
- linux-users.md - User and group management
- linux-scripting.md - Bash scripting
- linux-packages.md - Package management

**Networking Exercises (5)**
- network-basics.md - Connectivity testing with ping and curl
- network-dns.md - DNS resolution
- network-ports.md - Port management
- network-troubleshooting.md - Debugging connectivity
- network-docker.md - Docker networking concepts

**Terraform Exercises (3)**
- terraform-basics.md - Terraform workflow
- terraform-variables.md - Variables and outputs
- terraform-modules.md - Module creation and usage

#### Documentation
- Comprehensive README with quick start guide
- Exercise index with learning paths
- Contributing guidelines
- Testing procedures
- Service configuration documentation
- Troubleshooting guide

#### Monitoring & Observability
- Prometheus configuration with scrape configs
- Grafana datasource provisioning
- Pre-configured dashboards:
  - Service Overview dashboard
  - Logs dashboard
- Loki configuration with retention policies
- Promtail log collection setup

### Fixed
- PostgreSQL credentials corrected (devops/devops123/playground)
- Grafana password corrected (admin123)
- Container names standardized (devops-ubuntu, devops-alpine)
- All exercise files updated with correct container names

### Documentation
- All exercises follow standardized format
- Progressive hints in collapsible sections
- Complete solutions with explanations
- Expected outputs for verification
- Additional resources and links

### Testing
- Environment startup validation procedures
- Service health check procedures
- Inter-service communication tests
- Port accessibility verification
- Volume persistence tests
- Kubernetes cluster validation

## [Unreleased]

### Planned Features
- Additional advanced exercises
- CI/CD pipeline examples
- Ansible playbook examples
- More monitoring dashboards
- Video tutorials
- Interactive progress tracking

### Known Issues
- None at this time

## Version History

### Version 1.0.0 (2026-01-19)
- Initial release
- 23 exercises across 5 domains
- 11 containerized services
- Kubernetes cluster support
- Comprehensive documentation

---

## How to Read This Changelog

- **Added**: New features or exercises
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed in future versions
- **Removed**: Features that have been removed
- **Fixed**: Bug fixes
- **Security**: Security-related changes

## Contributing

See [Contributing Guide](03-contributing.md) for information on how to contribute to this project.

