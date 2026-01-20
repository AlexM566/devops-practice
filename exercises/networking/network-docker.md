# Docker Networking: Networks, Isolation, and Communication

**Difficulty:** Intermediate
**Estimated Time:** 40 minutes
**Prerequisites:** network-basics.md, docker-networking.md (from Docker exercises)

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how Docker networking works, understand different network drivers (bridge, host, none), explore network isolation, and practice connecting containers across networks. You'll gain hands-on experience with Docker's networking features and understand how the playground environment is structured.

## Instructions

### Part 1: Explore Existing Docker Networks

1. List all Docker networks:
```bash
docker network ls
```

2. Inspect the playground's networks:
```bash
# Inspect the frontend network
docker network inspect devops-practice_frontend

# Inspect the backend network
docker network inspect devops-practice_backend

# Inspect the monitoring network
docker network inspect devops-practice_monitoring
```

3. See which containers are on each network:
```bash
# Frontend network containers
docker network inspect devops-practice_frontend -f '{{range .Containers}}{{.Name}} {{end}}'

# Backend network containers
docker network inspect devops-practice_backend -f '{{range .Containers}}{{.Name}} {{end}}'
```

4. Check a container's network configuration:
```bash
docker inspect devops-nginx | grep -A 20 Networks
```

### Part 2: Test Network Isolation

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Check which networks this container is connected to:
```bash
# Install tools if needed
apt-get update && apt-get install -y net-tools iputils-ping curl netcat-openbsd

# Check network interfaces
ip addr show

# Check routing table
ip route
```

3. Test connectivity to services on different networks:
```bash
# Test services on networks you're connected to
ping -c 2 nginx-web
ping -c 2 nodejs-api

# Try to reach services on networks you're NOT connected to
# (This may fail depending on network configuration)
ping -c 2 postgres
ping -c 2 redis
```

4. Understand network isolation:
```bash
# Services on the same network can communicate
curl http://nginx-web:80

# Services on different networks may not be able to communicate
# unless explicitly connected to multiple networks
```

### Part 3: Create Custom Networks

1. Exit the container and create a new bridge network:
```bash
exit

# Create a custom bridge network
docker network create --driver bridge my-test-network

# Inspect it
docker network inspect my-test-network
```

2. Create test containers on this network:
```bash
# Create first container
docker run -d --name test-web --network my-test-network nginx:alpine

# Create second container
docker run -d --name test-client --network my-test-network alpine sleep 3600
```

3. Test connectivity between containers:
```bash
# Access the client container
docker exec -it test-client sh

# Install curl
apk add --no-cache curl

# Test connectivity using service name
curl http://test-web:80

# Exit
exit
```

4. Clean up test containers:
```bash
docker stop test-web test-client
docker rm test-web test-client
docker network rm my-test-network
```

### Part 4: Connect Containers to Multiple Networks

1. Create two separate networks:
```bash
docker network create network-a
docker network create network-b
```

2. Create containers on different networks:
```bash
# Container on network-a
docker run -d --name container-a --network network-a alpine sleep 3600

# Container on network-b
docker run -d --name container-b --network network-b alpine sleep 3600

# Container on both networks (bridge container)
docker run -d --name container-bridge --network network-a alpine sleep 3600
docker network connect network-b container-bridge
```

3. Test connectivity:
```bash
# Install tools in containers
docker exec container-a apk add --no-cache iputils

# Try to ping from container-a to container-b (should fail)
docker exec container-a ping -c 2 container-b

# Try to ping from container-a to container-bridge (should succeed)
docker exec container-a ping -c 2 container-bridge

# Try to ping from container-b to container-bridge (should succeed)
docker exec container-b ping -c 2 container-bridge
```

4. Verify the bridge container is on both networks:
```bash
docker inspect container-bridge | grep -A 30 Networks
```

5. Clean up:
```bash
docker stop container-a container-b container-bridge
docker rm container-a container-b container-bridge
docker network rm network-a network-b
```

### Part 5: Explore Network Drivers

**Bridge Network (Default):**

1. Create a container with default bridge network:
```bash
docker run -d --name bridge-test nginx:alpine
docker inspect bridge-test | grep -A 10 Networks
```

2. Note that it's on the default "bridge" network

**Host Network:**

1. Create a container with host network:
```bash
docker run -d --name host-test --network host nginx:alpine
```

2. Check that it shares the host's network namespace:
```bash
# The container uses the host's network directly
# No port mapping needed - it binds directly to host ports
docker inspect host-test | grep -A 10 Networks
```

3. Test access (nginx will be on host's port 8080):
```bash
# This should work without conflicts now
curl http://localhost:8080
```

4. Clean up:
```bash
docker stop host-test
docker rm host-test
```

**None Network:**

1. Create a container with no network:
```bash
docker run -d --name none-test --network none alpine sleep 3600
```

2. Verify it has no network access:
```bash
docker exec none-test ip addr show
# Should only show loopback interface (lo)

# Try to ping (should fail)
docker exec none-test ping -c 2 8.8.8.8 || echo "No network access"
```

3. Clean up:
```bash
docker stop none-test bridge-test
docker rm none-test bridge-test
```

### Part 6: Network Troubleshooting in Docker

1. Debug network connectivity issues:
```bash
# Check if a container is on the expected network
docker inspect CONTAINER_NAME | grep -A 20 Networks

# List all containers on a network
docker network inspect NETWORK_NAME

# Check container's IP address
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' CONTAINER_NAME
```

2. Test DNS resolution in containers:
```bash
docker exec -it devops-ubuntu bash

# Check DNS configuration
cat /etc/resolv.conf
# Should show 127.0.0.11 (Docker's embedded DNS)

# Test service name resolution
nslookup nginx-web
nslookup postgres

exit
```

3. Monitor network traffic:
```bash
# Install tcpdump in a container
docker exec -it devops-ubuntu bash
apt-get update && apt-get install -y tcpdump

# Capture traffic
tcpdump -i any -n host postgres

# In another terminal, generate traffic
docker exec devops-ubuntu ping -c 3 postgres
```

### Part 7: Understand the Playground Network Architecture

1. Visualize the network structure:
```bash
# Create a script to show network topology
cat > show-networks.sh << 'EOF'
#!/bin/bash

echo "=== Docker Networks in Playground ==="
echo ""

for network in $(docker network ls --filter name=devops-practice --format '{{.Name}}'); do
  echo "Network: $network"
  echo "Containers:"
  docker network inspect $network -f '{{range .Containers}}  - {{.Name}}{{println}}{{end}}'
  echo ""
done
EOF

chmod +x show-networks.sh
./show-networks.sh
```

2. Understand the network design:
```bash
# Frontend network: Web-facing services
# - nginx-web
# - nodejs-api

# Backend network: Data services
# - postgres
# - redis

# Monitoring network: Observability stack
# - prometheus
# - grafana
# - loki
# - promtail

# Some containers may be on multiple networks for cross-communication
```

3. Test cross-network communication:
```bash
# Check if nodejs-api can reach postgres
docker exec devops-nodejs-api sh -c "nc -zv postgres 5432" 2>&1

# Check if prometheus can reach nodejs-api
docker exec devops-prometheus sh -c "wget -q -O- http://nodejs-api:3000/metrics" | head -5
```

## Expected Output

**docker network ls:**
```
NETWORK ID     NAME                              DRIVER    SCOPE
abc123def456   bridge                            bridge    local
def456ghi789   devops-practice_frontend        bridge    local
ghi789jkl012   devops-practice_backend         bridge    local
jkl012mno345   devops-practice_monitoring      bridge    local
```

**docker network inspect (excerpt):**
```json
{
    "Name": "devops-practice_frontend",
    "Driver": "bridge",
    "Containers": {
        "abc123": {
            "Name": "devops-nginx",
            "IPv4Address": "172.20.0.2/16"
        }
    }
}
```

**Connectivity test:**
```
# Same network - SUCCESS
$ docker exec container-a ping -c 2 container-bridge
PING container-bridge (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.123 ms

# Different network - FAILURE
$ docker exec container-a ping -c 2 container-b
ping: bad address 'container-b'
```

## Verification Steps

- docker network ls should show playground networks
- Containers should be able to communicate on the same network
- Containers on different networks should be isolated (unless connected to both)
- Service names should resolve via Docker's DNS
- Host network containers should share the host's network namespace
- None network containers should have no network access

## Hints

<details>
<summary>Hint 1: Docker Network Drivers</summary>

Docker supports several network drivers:

- **bridge**: Default, creates isolated network on host
- **host**: Container shares host's network namespace
- **none**: No networking
- **overlay**: Multi-host networking (Swarm/Kubernetes)
- **macvlan**: Assign MAC address to container

For most use cases, bridge networks are sufficient.
</details>

<details>
<summary>Hint 2: Network Isolation</summary>

Containers on different bridge networks cannot communicate by default. This provides:
- **Security**: Isolate sensitive services
- **Organization**: Group related services
- **Traffic control**: Limit communication paths

To allow communication, connect containers to multiple networks or use a bridge container.
</details>

<details>
<summary>Hint 3: Docker DNS</summary>

Docker provides automatic DNS resolution:
- Service names resolve to container IPs
- DNS server at 127.0.0.11 in each container
- Only works for containers on the same network
- Updates automatically when containers start/stop

This is why you can use `postgres` instead of `172.18.0.5`!
</details>

<details>
<summary>Hint 4: Port Publishing vs Network Connection</summary>

Two ways to access containers:

1. **Port Publishing** (`-p 8080:80`):
   - Exposes container port to host
   - Accessible from outside Docker
   - Uses host's IP address

2. **Network Connection** (same network):
   - Containers communicate directly
   - Uses service names
   - Not accessible from host (unless port published)

The playground uses both!
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

### Complete Solution

**Step 1: Explore existing networks**
```bash
# List all networks
docker network ls
# Shows: bridge, devops-practice_frontend, backend, monitoring

# Inspect a network
docker network inspect devops-practice_frontend
# Shows: containers, subnet, gateway

# See containers on network
docker network inspect devops-practice_frontend -f '{{range .Containers}}{{.Name}} {{end}}'
```

**Step 2: Test network isolation**
```bash
docker exec -it devops-ubuntu bash

# Check interfaces
ip addr show
# Shows: lo, eth0, eth1, etc. (one per network)

# Test connectivity
ping -c 2 nginx-web  # Should work (same network)
ping -c 2 postgres   # May work (if on same network)

exit
```

**Step 3: Create and test custom network**
```bash
# Create network
docker network create my-test-network

# Create containers
docker run -d --name test-web --network my-test-network nginx:alpine
docker run -d --name test-client --network my-test-network alpine sleep 3600

# Test connectivity
docker exec test-client sh -c "apk add curl && curl http://test-web:80"
# Should succeed - same network

# Cleanup
docker stop test-web test-client
docker rm test-web test-client
docker network rm my-test-network
```

**Step 4: Multi-network containers**
```bash
# Create networks
docker network create network-a
docker network create network-b

# Create containers
docker run -d --name container-a --network network-a alpine sleep 3600
docker run -d --name container-b --network network-b alpine sleep 3600
docker run -d --name container-bridge --network network-a alpine sleep 3600

# Connect bridge to second network
docker network connect network-b container-bridge

# Test isolation
docker exec container-a sh -c "apk add iputils && ping -c 2 container-b" || echo "Isolated!"
# Should fail - different networks

docker exec container-a sh -c "ping -c 2 container-bridge"
# Should succeed - same network

# Cleanup
docker stop container-a container-b container-bridge
docker rm container-a container-b container-bridge
docker network rm network-a network-b
```

**Step 5: Test different network drivers**
```bash
# Host network
docker run -d --name host-test --network host nginx:alpine
docker inspect host-test | grep -A 10 Networks
# Shows: "host" network, no IP address (uses host's)

# None network
docker run -d --name none-test --network none alpine sleep 3600
docker exec none-test ip addr show
# Shows: only loopback (127.0.0.1)

# Cleanup
docker stop host-test none-test
docker rm host-test none-test
```

**Step 6: Understand playground architecture**
```bash
# Show network topology
for network in $(docker network ls --filter name=devops-practice --format '{{.Name}}'); do
  echo "=== $network ==="
  docker network inspect $network -f '{{range .Containers}}{{.Name}}{{println}}{{end}}'
done

# Test cross-network communication
docker exec devops-nodejs-api sh -c "nc -zv postgres 5432"
# Works if nodejs-api is on backend network
```

### Explanation

**Docker Networking Architecture:**

1. **Bridge Networks**: Create isolated virtual networks on the host. Containers on the same bridge can communicate; containers on different bridges cannot (by default).

2. **Network Drivers**:
   - **bridge**: Isolated network, most common
   - **host**: No isolation, shares host network
   - **none**: No network access at all

3. **DNS Resolution**: Docker runs a DNS server (127.0.0.11) in each container that resolves service names to IPs for containers on the same network.

4. **Multi-Network Containers**: A container can be connected to multiple networks, acting as a bridge between them.

**Playground Network Design:**

- **frontend**: Web-facing services (nginx, nodejs-api)
- **backend**: Data services (postgres, redis)
- **monitoring**: Observability (prometheus, grafana, loki)

This separation provides:
- **Security**: Database not directly accessible from frontend
- **Organization**: Related services grouped together
- **Flexibility**: Easy to add/remove services per network

**Best Practices:**

1. Use custom bridge networks (not default bridge)
2. Group related services on the same network
3. Use service names, not IP addresses
4. Minimize cross-network connections
5. Use network isolation for security

</details>

## Additional Resources

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Network Drivers](https://docs.docker.com/network/drivers/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Container Networking Best Practices](https://www.docker.com/blog/understanding-docker-networking-drivers-use-cases/)
- [Docker DNS Resolution](https://docs.docker.com/config/containers/container-networking/#dns-services)
