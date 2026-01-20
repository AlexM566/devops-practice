# DevOps Interview Playground

A comprehensive Docker Compose-based practice environment for learning and mastering essential DevOps skills. This playground provides hands-on access to real-world tools and services, along with guided exercises to help you prepare for DevOps interviews and improve your technical skills.

## Features

- **Multi-Service Environment**: Pre-configured web applications, databases, monitoring stack, and more
- **Kubernetes Practice**: Local kind cluster for container orchestration exercises
- **Monitoring & Observability**: Prometheus, Grafana, and Loki for metrics and logging
- **Guided Exercises**: 25+ markdown-based exercises across 5 technology domains
- **Realistic Architecture**: Production-like multi-tier application setup
- **Linux Practice Containers**: Ubuntu and Alpine containers with common DevOps tools
- **Terraform Examples**: Infrastructure-as-code practice with working examples
- **No Complex Setup**: Single `docker-compose up` command to start everything

## Documentation

- [Exercise Index](02-exercises.md) - Complete list of all exercises
- [Contributing Guide](03-contributing.md) - Guidelines for contributors
- [Testing Guide](04-testing.md) - Environment testing procedures
- [Changelog](05-changelog.md) - Version history and changes

## Prerequisites

Before using the DevOps Interview Playground, ensure you have the following installed:

### Required Software

- **Docker Desktop** (version 20.10 or higher)
  - Download: https://www.docker.com/products/docker-desktop
  - Includes Docker Engine and Docker Compose
  
- **WSL 2** (Windows users only)
  - Required for Docker Desktop on Windows
  - Installation guide: https://docs.microsoft.com/en-us/windows/wsl/install

- **kind** (Kubernetes in Docker)
  - Installation: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
  
- **kubectl** (Kubernetes CLI)
  - Installation: https://kubernetes.io/docs/tasks/tools/

- **Terraform** (optional, for Terraform exercises)
  - Download: https://www.terraform.io/downloads

### System Requirements

- **RAM**: Minimum 8GB (16GB recommended)
- **Disk Space**: At least 20GB free space
- **CPU**: 4 cores recommended
- **Operating System**: Windows 10/11 (with WSL 2), macOS, or Linux

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd devops-playground
```

### 2. Start the Environment

```bash
docker-compose up -d
```

This command will:
- Pull all required Docker images
- Create networks and volumes
- Start all services in the background
- Configure monitoring and logging

### 3. Verify Services

Check that all services are running:

```bash
docker-compose ps
```

All services should show status as "Up" or "healthy".

### 4. Access Services

Open your browser and access the services using the URLs listed below.

### 5. Start Learning

Browse the exercises in the `exercises/` directory or check out [Exercise Index](02-exercises.md) for a complete index.

## Available Services

### Web Applications

| Service | URL | Description | Credentials |
|---------|-----|-------------|-------------|
| Nginx Web Server | http://localhost:80 | Static web server and reverse proxy | N/A |
| Node.js API | http://localhost:3000 | Sample REST API with health endpoint | N/A |

### Databases

| Service | URL | Description | Credentials |
|---------|-----|-------------|-------------|
| PostgreSQL | localhost:5432 | Relational database | User: `devops`<br>Password: `devops123`<br>Database: `playground` |
| Redis | localhost:6379 | In-memory cache and message broker | No password |

### Monitoring & Observability

| Service | URL | Description | Credentials |
|---------|-----|-------------|-------------|
| Prometheus | http://localhost:9090 | Metrics collection and monitoring | N/A |
| Grafana | http://localhost:3001 | Metrics visualization and dashboards | User: `admin`<br>Password: `admin123` |
| Loki | http://localhost:3100 | Log aggregation system | N/A |

### Practice Containers

| Service | Description | Access Command |
|---------|-------------|----------------|
| Ubuntu Practice | Ubuntu container with common tools | `docker exec -it devops-ubuntu bash` |
| Alpine Practice | Minimal Alpine Linux container | `docker exec -it devops-alpine sh` |

### Kubernetes

| Service | Description | Access Command |
|---------|-------------|----------------|
| kind Cluster | Local Kubernetes cluster | `kubectl cluster-info --context kind-devops-playground` |

## Service Details

### Node.js API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint
- `GET /metrics` - Prometheus metrics endpoint

### Grafana Dashboards

Pre-configured dashboards available after login:
- **Service Overview**: CPU, memory, and network metrics for all services
- **Logs Dashboard**: Aggregated logs from all containers

### Prometheus Targets

Prometheus is configured to scrape metrics from:
- Node.js API (`/metrics` endpoint)
- Prometheus itself
- Additional services can be added in `services/prometheus/prometheus.yml`

## Stopping the Environment

To stop all services:

```bash
docker-compose down
```

To stop and remove all data (volumes):

```bash
docker-compose down -v
```

## Kubernetes Setup

### Create the kind Cluster

```bash
cd kubernetes
./setup-k8s.sh
```

This script will:
- Create a multi-node kind cluster (1 control plane, 2 workers)
- Configure kubectl context
- Verify cluster is ready

### Verify Kubernetes Cluster

```bash
kubectl get nodes
kubectl get pods -A
```

### Delete the Cluster

```bash
kind delete cluster --name devops-playground
```

## Troubleshooting

### Docker Daemon Not Running

**Error**: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock`

**Solution**:
- Ensure Docker Desktop is running
- On Linux, start Docker: `sudo systemctl start docker`
- Verify with: `docker ps`

### Port Already in Use

**Error**: `Bind for 0.0.0.0:XXXX failed: port is already allocated`

**Solution**:
- Check what's using the port: `lsof -i :XXXX` (macOS/Linux) or `netstat -ano | findstr :XXXX` (Windows)
- Stop the conflicting service or modify the port in `docker-compose.yml`
- Common conflicts: port 80 (web servers), 5432 (PostgreSQL), 3000 (development servers)

### Services Not Starting / Unhealthy

**Error**: Services show as "unhealthy" or fail to start

**Solution**:
- Check service logs: `docker-compose logs SERVICE_NAME`
- Verify sufficient resources in Docker Desktop settings (increase RAM/CPU)
- Try restarting the service: `docker-compose restart SERVICE_NAME`
- Check for image pull errors: `docker-compose pull`

### Insufficient Resources

**Error**: Container exits with code 137 or services are slow

**Solution**:
- Increase Docker Desktop resource limits:
  - Docker Desktop → Settings → Resources
  - Increase Memory to at least 8GB
  - Increase CPUs to at least 4 cores
- Stop unnecessary services: `docker-compose stop SERVICE_NAME`

### kind Cluster Creation Fails

**Error**: `ERROR: failed to create cluster: ...`

**Solution**:
- Ensure Docker has sufficient resources (8GB RAM minimum)
- Check for port conflicts (kind uses ports 80, 443, and random high ports)
- Delete existing cluster: `kind delete cluster --name devops-playground`
- Try creating again: `cd kubernetes && ./setup-k8s.sh`

### kubectl Cannot Connect

**Error**: `The connection to the server localhost:8080 was refused`

**Solution**:
- Verify kind cluster is running: `kind get clusters`
- Set the correct context: `kubectl config use-context kind-devops-playground`
- Check kubeconfig: `kubectl config view`

### Grafana Shows No Data

**Problem**: Grafana dashboards are empty

**Solution**:
- Verify Prometheus is running: `docker-compose ps prometheus`
- Check Prometheus targets: http://localhost:9090/targets (should show "UP")
- Wait a few minutes for metrics to be collected
- Verify data source in Grafana: Configuration → Data Sources

### Cannot Access Services from Host

**Problem**: Cannot reach services at localhost URLs

**Solution**:
- Verify services are running: `docker-compose ps`
- Check port mappings: `docker-compose port SERVICE_NAME PORT`
- On Windows with WSL, try using the WSL IP instead of localhost
- Check firewall settings

### Image Pull Failures

**Error**: `Error response from daemon: pull access denied`

**Solution**:
- Check internet connection
- Verify image names in `docker-compose.yml`
- Try pulling manually: `docker pull IMAGE_NAME`
- Check Docker Hub rate limits (may need to login: `docker login`)

### Exercise Commands Not Working

**Problem**: Commands in exercises produce unexpected results

**Solution**:
- Ensure you're in the correct directory
- Verify you're in the right container: `docker exec -it CONTAINER_NAME bash`
- Check service is running: `docker-compose ps SERVICE_NAME`
- Review exercise prerequisites and previous steps
- Check hints section in the exercise file
- Compare with solution (in collapsible section)

## Getting Help

If you encounter issues not covered here:

1. Check service logs: `docker-compose logs SERVICE_NAME`
2. Review the exercise hints and solution sections
3. Verify all prerequisites are installed and up to date
4. Try restarting the environment: `docker-compose restart`
5. Check Docker Desktop resource allocation

## Next Steps

Ready to start learning? Check out:

- [Exercise Index](02-exercises.md) - Complete index of all exercises
- `exercises/docker/` - Start with Docker basics
- `exercises/linux/` - Practice Linux administration
- `exercises/kubernetes/` - Learn container orchestration

## Contributing

Interested in adding exercises or improving the playground? See [Contributing Guide](03-contributing.md) for guidelines.

## License

This project is provided as-is for educational purposes.

