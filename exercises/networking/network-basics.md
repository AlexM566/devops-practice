# Network Basics: Testing Connectivity

**Difficulty:** Beginner
**Estimated Time:** 20 minutes
**Prerequisites:** Basic command line knowledge

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to test network connectivity between containers and external services using fundamental networking tools like ping and curl. You'll verify that services can communicate with each other and access external resources.

## Instructions

### Part 1: Test Container Connectivity with Ping

1. Start the playground environment if it's not already running:
```bash
docker-compose up -d
```

2. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

3. Test connectivity to another container using its service name:
```bash
ping -c 4 postgres
```

4. Test connectivity to the Redis container:
```bash
ping -c 4 redis
```

5. Test connectivity to an external service (Google DNS):
```bash
ping -c 4 8.8.8.8
```

### Part 2: Test HTTP Connectivity with Curl

1. From within the Ubuntu container, test the Node.js API service:
```bash
curl http://nodejs-api:3000/health
```

2. Test the Nginx web server:
```bash
curl http://nginx-web:80
```

3. Test the Prometheus service:
```bash
curl http://prometheus:9090/-/healthy
```

4. Test an external HTTP endpoint:
```bash
curl -I https://www.google.com
```

### Part 3: Test Service Ports from Host

1. Exit the container (type `exit` or press Ctrl+D)

2. From your host machine, test the web server:
```bash
curl http://localhost:80
```

3. Test the API health endpoint:
```bash
curl http://localhost:3000/health
```

4. Test Prometheus:
```bash
curl http://localhost:9090/-/healthy
```

## Expected Output

**Ping to postgres:**
```
PING postgres (172.X.X.X) 56(84) bytes of data.
64 bytes from devops-playground-postgres-1.backend (172.X.X.X): icmp_seq=1 ttl=64 time=0.XXX ms
64 bytes from devops-playground-postgres-1.backend (172.X.X.X): icmp_seq=2 ttl=64 time=0.XXX ms
...
--- postgres ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
```

**Curl to nodejs-api:**
```json
{"status":"healthy","timestamp":"2024-XX-XXTXX:XX:XX.XXXZ"}
```

**Curl to nginx-web:**
```html
<!DOCTYPE html>
<html>
...
</html>
```

## Verification Steps

- Ping commands should show 0% packet loss
- Curl commands should return HTTP 200 status codes
- Service names should resolve to IP addresses
- All services should be reachable from within containers
- Exposed services should be accessible from the host machine

## Hints

<details>
<summary>Hint 1: Ping Not Found</summary>

If ping is not available in the container, you may need to install it:
```bash
apt-get update && apt-get install -y iputils-ping
```

The Ubuntu practice container should already have this installed.
</details>

<details>
<summary>Hint 2: Service Name Resolution</summary>

Docker Compose automatically creates DNS entries for service names. When you ping `postgres`, Docker's internal DNS resolves it to the container's IP address on the shared network.
</details>

<details>
<summary>Hint 3: Connection Refused</summary>

If you get "Connection refused", check that:
- The service is running: `docker-compose ps`
- The service is healthy: `docker-compose ps | grep SERVICE_NAME`
- You're using the correct port number
- The containers are on the same network
</details>

<details>
<summary>Hint 4: Understanding Networks</summary>

Containers can communicate using service names only if they're on the same Docker network. Check which networks a container is connected to:
```bash
docker inspect CONTAINER_NAME | grep -A 10 Networks
```
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

### Complete Solution

**Step 1: Access the Ubuntu container**
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
```

**Step 2: Test inter-container connectivity**
```bash
# Ping PostgreSQL (should succeed with 0% packet loss)
ping -c 4 postgres

# Ping Redis (should succeed with 0% packet loss)
ping -c 4 redis

# Ping external service (should succeed)
ping -c 4 8.8.8.8
```

**Step 3: Test HTTP services**
```bash
# Test Node.js API
curl http://nodejs-api:3000/health
# Expected: {"status":"healthy","timestamp":"..."}

# Test Nginx
curl http://nginx-web:80
# Expected: HTML content

# Test Prometheus
curl http://prometheus:9090/-/healthy
# Expected: Prometheus is Healthy.

# Test external HTTP
curl -I https://www.google.com
# Expected: HTTP/2 200
```

**Step 4: Exit and test from host**
```bash
exit
```

**Step 5: Test from host machine**
```bash
# Test web server
curl http://localhost:80

# Test API
curl http://localhost:3000/health

# Test Prometheus
curl http://localhost:9090/-/healthy
```

### Explanation

**Why This Works:**

1. **Docker DNS**: Docker Compose creates an internal DNS server that resolves service names to container IP addresses. When you ping `postgres`, Docker's DNS returns the IP of the postgres container.

2. **Docker Networks**: Containers on the same network can communicate directly. The docker-compose.yml defines networks (frontend, backend, monitoring) that connect related services.

3. **Port Mapping**: Services with ports exposed in docker-compose.yml (e.g., `80:80`) are accessible from the host machine at those ports.

4. **Service Discovery**: Using service names instead of IP addresses makes configurations portable and resilient to container restarts (which may change IPs).

</details>

## Additional Resources

- [Docker Networking Overview](https://docs.docker.com/network/)
- [Docker Compose Networking](https://docs.docker.com/compose/networking/)
- [Linux ping command](https://linux.die.net/man/8/ping)
- [curl command guide](https://curl.se/docs/manual.html)
