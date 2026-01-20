# Network Ports: Port Scanning and Connectivity

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Basic networking knowledge, network-basics.md

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to identify listening ports, check port connectivity, and understand which services are running on which ports. You'll use netstat, ss, lsof, and telnet/nc to investigate network ports and test connectivity.

## Instructions

### Part 1: Install Network Tools

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
```

2. Install network utilities:
```bash
apt-get update && apt-get install -y net-tools netcat-openbsd telnet
```

### Part 2: Check Listening Ports

1. Use netstat to see all listening TCP ports:
```bash
netstat -tuln
```

2. Use ss (modern alternative to netstat) to see listening ports:
```bash
ss -tuln
```

3. Filter for specific ports:
```bash
# Check if port 80 is listening
netstat -tuln | grep :80

# Check if port 5432 is listening
netstat -tuln | grep :5432
```

4. See which processes are using ports (requires running in the service container):
```bash
# Exit Ubuntu container
exit

# Access the postgres container
docker exec -it devops-playground-postgres-1 sh

# Install net-tools if needed
apt-get update && apt-get install -y net-tools procps

# See what's listening
netstat -tulnp

# Exit back to host
exit
```

### Part 3: Test Port Connectivity

1. Return to the Ubuntu practice container:
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
```

2. Test if a port is open using netcat (nc):
```bash
# Test PostgreSQL port
nc -zv postgres 5432

# Test Redis port
nc -zv redis 6379

# Test Nginx port
nc -zv nginx-web 80

# Test Node.js API port
nc -zv nodejs-api 3000
```

3. Test multiple ports at once:
```bash
# Test a range of ports on postgres
nc -zv postgres 5430-5435
```

4. Use telnet to test connectivity:
```bash
# Test HTTP port (type 'quit' to exit)
telnet nginx-web 80

# Test PostgreSQL port (Ctrl+] then 'quit' to exit)
telnet postgres 5432
```

### Part 4: Test Ports from Host Machine

1. Exit the container:
```bash
exit
```

2. From your host machine, check which ports Docker is exposing:
```bash
docker-compose ps
```

3. Test connectivity to exposed ports:
```bash
# Test with netcat (if available)
nc -zv localhost 80
nc -zv localhost 3000
nc -zv localhost 5432

# Test with telnet
telnet localhost 80
telnet localhost 9090
```

4. Use curl to test HTTP ports:
```bash
curl -v http://localhost:80
curl -v http://localhost:3000/health
curl -v http://localhost:9090/-/healthy
```

### Part 5: Scan for Open Ports

1. Back in the Ubuntu container, scan a service for open ports:
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
```

2. Scan common ports on postgres:
```bash
for port in 22 80 443 5432 5433 8080; do
  nc -zv -w 1 postgres $port 2>&1 | grep -E "succeeded|open"
done
```

3. Create a simple port scanner script:
```bash
cat > portscan.sh << 'EOF'
#!/bin/bash
HOST=$1
START_PORT=$2
END_PORT=$3

echo "Scanning $HOST from port $START_PORT to $END_PORT..."

for port in $(seq $START_PORT $END_PORT); do
  nc -zv -w 1 $HOST $port 2>&1 | grep -E "succeeded|open" && echo "Port $port is open"
done
EOF

chmod +x portscan.sh
```

4. Run the port scanner:
```bash
./portscan.sh postgres 5430 5435
./portscan.sh redis 6370 6380
```

## Expected Output

**netstat -tuln:**
```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:3000            0.0.0.0:*               LISTEN
tcp        0      0 0.0.0.0:5432            0.0.0.0:*               LISTEN
```

**nc -zv postgres 5432:**
```
Connection to postgres 5432 port [tcp/postgresql] succeeded!
```

**nc -zv postgres 8080:**
```
nc: connect to postgres port 8080 (tcp) failed: Connection refused
```

**docker-compose ps (ports column):**
```
0.0.0.0:80->80/tcp
0.0.0.0:3000->3000/tcp
0.0.0.0:5432->5432/tcp
0.0.0.0:6379->6379/tcp
```

## Verification Steps

- netstat/ss should show listening ports for services
- nc should successfully connect to open ports
- nc should fail to connect to closed ports
- telnet should establish connections to listening services
- Port scans should identify only the expected open ports
- docker-compose ps should show port mappings

## Hints

<details>
<summary>Hint 1: Understanding netstat Output</summary>

netstat flags:
- **-t**: Show TCP connections
- **-u**: Show UDP connections
- **-l**: Show only listening sockets
- **-n**: Show numerical addresses (don't resolve names)
- **-p**: Show process ID and name (requires privileges)

State meanings:
- **LISTEN**: Port is open and waiting for connections
- **ESTABLISHED**: Active connection
- **TIME_WAIT**: Connection closed, waiting for cleanup
</details>

<details>
<summary>Hint 2: netcat (nc) Flags</summary>

Common nc flags:
- **-z**: Zero-I/O mode (just scan, don't send data)
- **-v**: Verbose output
- **-w N**: Timeout after N seconds
- **-u**: Use UDP instead of TCP

Example: `nc -zv -w 2 hostname port`
</details>

<details>
<summary>Hint 3: Port Numbers and Services</summary>

Common port numbers:
- **22**: SSH
- **80**: HTTP
- **443**: HTTPS
- **3000**: Node.js applications (common)
- **3306**: MySQL
- **5432**: PostgreSQL
- **6379**: Redis
- **8080**: Alternative HTTP
- **9090**: Prometheus
</details>

<details>
<summary>Hint 4: Connection Refused vs Timeout</summary>

- **Connection refused**: Port is closed, but host is reachable
- **Timeout**: Host is unreachable or firewall is blocking
- **Succeeded**: Port is open and accepting connections

This helps diagnose network issues!
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

### Complete Solution

**Step 1: Install tools and check listening ports**
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
apt-get update && apt-get install -y net-tools netcat-openbsd telnet

# View all listening ports
netstat -tuln
# Shows ports that services are listening on

# Modern alternative
ss -tuln
# Same information, faster performance
```

**Step 2: Test port connectivity with netcat**
```bash
# Test database ports
nc -zv postgres 5432
# Output: Connection to postgres 5432 port [tcp/postgresql] succeeded!

nc -zv redis 6379
# Output: Connection to redis 6379 port [tcp/redis] succeeded!

# Test web services
nc -zv nginx-web 80
# Output: Connection to nginx-web 80 port [tcp/http] succeeded!

nc -zv nodejs-api 3000
# Output: Connection to nodejs-api 3000 port [tcp/*] succeeded!

# Test closed port (should fail)
nc -zv postgres 8080
# Output: nc: connect to postgres port 8080 (tcp) failed: Connection refused
```

**Step 3: Scan port ranges**
```bash
# Scan multiple ports
nc -zv postgres 5430-5435
# Only 5432 should succeed

# Create port scanner
cat > portscan.sh << 'EOF'
#!/bin/bash
HOST=$1
START_PORT=$2
END_PORT=$3

echo "Scanning $HOST from port $START_PORT to $END_PORT..."

for port in $(seq $START_PORT $END_PORT); do
  if nc -zv -w 1 $HOST $port 2>&1 | grep -q "succeeded"; then
    echo "✓ Port $port is OPEN"
  fi
done
EOF

chmod +x portscan.sh

# Run scanner
./portscan.sh postgres 5430 5435
# Output: ✓ Port 5432 is OPEN
```

**Step 4: Test from host machine**
```bash
exit  # Exit container

# Check exposed ports
docker-compose ps
# Shows port mappings like 0.0.0.0:5432->5432/tcp

# Test with curl
curl -v http://localhost:80
curl -v http://localhost:3000/health
curl -v http://localhost:9090/-/healthy

# Test with netcat (if available on host)
nc -zv localhost 80
nc -zv localhost 5432
```

**Step 5: Check which process uses a port**
```bash
# Access a service container
docker exec -it devops-playground-postgres-1 sh

# Install tools
apt-get update && apt-get install -y net-tools procps

# See process using port
netstat -tulnp
# Shows PID and program name for each listening port

# Alternative with ss
ss -tulnp

exit
```

### Explanation

**How Port Connectivity Works:**

1. **Listening Ports**: A service "listens" on a port, waiting for incoming connections. Use `netstat -tuln` to see all listening ports.

2. **Port States**:
   - **Open**: Service is listening and accepting connections
   - **Closed**: No service listening, connection refused
   - **Filtered**: Firewall blocking, connection times out

3. **Docker Port Mapping**: Docker can map container ports to host ports:
   - `5432:5432` maps container port 5432 to host port 5432
   - `8080:80` maps container port 80 to host port 8080

4. **Testing Connectivity**:
   - **netcat (nc)**: Quick port scanning and testing
   - **telnet**: Interactive connection testing
   - **curl**: HTTP-specific testing with full request/response

**Why Use Different Tools:**

- **netstat/ss**: See what YOUR system is listening on
- **nc**: Test if REMOTE ports are open
- **telnet**: Interactive testing with manual commands
- **curl**: HTTP-specific with headers and response codes

**Security Note**: Port scanning can be detected by security systems. Only scan systems you own or have permission to test!

</details>

## Additional Resources

- [netstat command guide](https://linux.die.net/man/8/netstat)
- [ss command guide](https://linux.die.net/man/8/ss)
- [netcat (nc) guide](https://linux.die.net/man/1/nc)
- [Common TCP/UDP Port Numbers](https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers)
- [Docker Port Mapping](https://docs.docker.com/config/containers/container-networking/#published-ports)
