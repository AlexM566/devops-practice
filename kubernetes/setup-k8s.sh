#!/bin/bash

# DevOps Interview Playground - Kubernetes Cluster Setup Script
# This script creates a kind cluster using the configuration in kind-config.yaml

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/kind-config.yaml"
CLUSTER_NAME="devops-playground"

echo "=========================================="
echo "DevOps Playground - Kubernetes Setup"
echo "=========================================="
echo ""

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo -e "${RED}Error: kind is not installed${NC}"
    echo "Please install kind from: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed${NC}"
    echo "Please install kubectl from: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker Desktop and try again"
    exit 1
fi

echo -e "${GREEN}✓${NC} Prerequisites check passed"
echo ""

# Check if cluster already exists
if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    echo -e "${YELLOW}Warning: Cluster '${CLUSTER_NAME}' already exists${NC}"
    read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Deleting existing cluster..."
        kind delete cluster --name "${CLUSTER_NAME}"
        echo -e "${GREEN}✓${NC} Cluster deleted"
    else
        echo "Using existing cluster"
        kubectl cluster-info --context "kind-${CLUSTER_NAME}"
        exit 0
    fi
fi

# Create data directory for volume mounts
DATA_DIR="${SCRIPT_DIR}/data"
if [ ! -d "${DATA_DIR}" ]; then
    echo "Creating data directory for volume mounts..."
    mkdir -p "${DATA_DIR}"
    echo -e "${GREEN}✓${NC} Data directory created: ${DATA_DIR}"
fi

# Create kind cluster
echo ""
echo "Creating kind cluster..."
echo "This may take a few minutes..."
echo ""

if kind create cluster --config "${CONFIG_FILE}"; then
    echo ""
    echo -e "${GREEN}✓${NC} Cluster created successfully"
else
    echo ""
    echo -e "${RED}Error: Failed to create cluster${NC}"
    exit 1
fi

# Wait for cluster to be ready
echo ""
echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

echo -e "${GREEN}✓${NC} Cluster is ready"

# Set kubectl context
echo ""
echo "Configuring kubectl context..."
kubectl config use-context "kind-${CLUSTER_NAME}"
echo -e "${GREEN}✓${NC} kubectl context set to kind-${CLUSTER_NAME}"

# Verification
echo ""
echo "=========================================="
echo "Cluster Verification"
echo "=========================================="
echo ""

echo "Cluster Info:"
kubectl cluster-info

echo ""
echo "Nodes:"
kubectl get nodes -o wide

echo ""
echo "Namespaces:"
kubectl get namespaces

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Cluster Name: ${CLUSTER_NAME}"
echo "Context: kind-${CLUSTER_NAME}"
echo "Nodes: 1 control-plane, 2 workers"
echo ""
echo "Next Steps:"
echo "  1. Deploy example resources:"
echo "     kubectl apply -f ${SCRIPT_DIR}/examples/"
echo ""
echo "  2. View deployed resources:"
echo "     kubectl get all"
echo ""
echo "  3. Access services via NodePort:"
echo "     http://localhost:30080"
echo ""
echo "  4. Delete cluster when done:"
echo "     kind delete cluster --name ${CLUSTER_NAME}"
echo ""
