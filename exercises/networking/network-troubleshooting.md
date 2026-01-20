# Network Troubleshooting: Debugging Connectivity Issues

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** network-basics.md, network-dns.md, network-ports.md

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn systematic approaches to diagnosing and resolving network connectivity issues. You'll use traceroute, tcpdump, and various diagnostic techniques to identify where network problems occur and how to fix them.

## Instructions

### Part 1: Install Troubleshooting Tools

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-ubuntu bash
```

2. Install network troubleshooting tools:
```bash
apt-get update && apt-get install -y \
  traceroute \
  tcpdump \
  mtr \
  dnsutils \
  net-tools \
  iputils-ping \
  curl \
  netcat-openbsd
```

### Part 2: Trace Network Routes

1. Use traceroute to see the path to an external host:
```bash
traceroute google.com
```

2. Trace the route to an internal service:
```bash
traceroute postgres
```

3. Use mtr (My TraceRoute) for continuous monitoring:
```bash
# Press 'q' to quit
mtr google.com
```

4. Trace with specific options:
```bash
# Use ICMP instead of UDP
traceroute -I google.com

# Limit to 10 hops
traceroute -m 10 google.com
```

### Part 3: Capture and Analyze Network Traffic

1. Capture traffic to a specific host (run in background):
```bash
# Capture traffic to postgres (Ctrl+C to stop)
tcpdump -i any host postgres
```

2. In another terminal, generate some traffic:
```bash
# Open another terminal
docker exec -it devops-ubuntu bash
curl http://nodejs-api:3000/health
ping -c 3 postgres
```

3. Capture traffic on a specific port:
```bash
# Capture HTTP traffic
tcpdump -i any port 80 -n

# In another terminal, generate HTTP traffic
curl http://nginx-web:80
```

4. Save captured traffic to a file:
```bash
# Capture 20 packets and save to file
tcpdump -i any -c 20 -w /tmp/capture.pcap

# Generate traffic
curl http://nodejs-api:3000/health

# Read the capture file
tcpdump -r /tmp/capture.pcap
```

5. Filter captured traffic:
```bash
# Capture only TCP SYN packets
tcpdump -i any 'tcp[tcpflags] & tcp-syn != 0'

# Capture DNS queries
tcpdump -i any port 53
```

### Part 4: Diagnose Common Issues

**Scenario 1: Service Not Responding**

1. Simulate a stopped service:
```bash
exit  # Exit container
docker-compose stop redis
```

2. Try to connect and diagnose:
```bash
docker exec -it devops-ubuntu bash

# Try to connect
nc -zv redis 6379
# Should fail with "Connection refused" or timeout

# Check if host resolves
nslookup redis
# Should still resolve (DNS works)

# Check if host is reachable
ping -c 3 redis
# May succeed (container exists) or fail (container stopped)

# Diagnose: Service is down
```

3. Fix the issue:
```bash
exit
docker-compose start redis

# Verify fix
docker exec -it devops-ubuntu bash
nc -zv redis 6379
# Should succeed now
```

**Scenario 2: DNS Resolution Failure**

1. Check DNS resolution:
```bash
# This should work
nslookup postgres

# Try a non-existent service
nslookup nonexistent-service
# Should fail with "server can't find"
```

2. Diagnose DNS issues:
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Test DNS server directly
dig @127.0.0.11 postgres

# Try external DNS
dig @8.8.8.8 google.com
```

**Scenario 3: Port Connectivity Issues**

1. Test port connectivity systematically:
```bash
# Step 1: Can we resolve the hostname?
nslookup nodejs-api
# If this fails, it's a DNS issue

# Step 2: Can we reach the host?
ping -c 3 nodejs-api
# If this fails, it's a network/routing issue

# Step 3: Is the port open?
nc -zv nodejs-api 3000
# If this fails, service isn't listening or firewall blocking

# Step 4: Can we make an HTTP request?
curl -v http://nodejs-api:3000/health
# If this fails, application issue
```

### Part 5: Network Performance Testing

1. Test latency to services:
```bash
# Measure round-trip time
ping -c 10 postgres | tail -1

# Continuous monitoring with statistics
ping -c 100 postgres | grep -E "min/avg/max"
```

2. Test bandwidth between containers:
```bash
# Install iperf3 (if needed for advanced testing)
apt-get install -y iperf3

# Note: This requires iperf3 server running on target
# For this exercise, we'll use simpler methods
```

3. Monitor network connections:
```bash
# Show all active connections
netstat -an | grep ESTABLISHED

# Watch connections in real-time
watch -n 1 'netstat -an | grep ESTABLISHED | wc -l'
```

### Part 6: Create a Troubleshooting Script

1. Create a comprehensive network diagnostic script:
```bash
cat > netdiag.sh << 'EOF'
#!/bin/bash

HOST=$1
PORT=$2

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Usage: $0 <host> <port>"
  exit 1
fi

echo "=== Network Diagnostic Tool ==="
echo "Target: $HOST:$PORT"
echo ""

echo "1. DNS Resolution:"
if nslookup $HOST > /dev/null 2>&1; then
  IP=$(nslookup $HOST | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
  echo "   ✓ DNS resolves to: $IP"
else
  echo "   ✗ DNS resolution failed"
  exit 1
fi

echo ""
echo "2. Host Reachability:"
if ping -c 3 -W 2 $HOST > /dev/null 2>&1; then
  echo "   ✓ Host is reachable (ping successful)"
else
  echo "   ⚠ Host not responding to ping (may be normal)"
fi

echo ""
echo "3. Port Connectivity:"
if nc -zv -w 2 $HOST $PORT 2>&1 | grep -q "succeeded"; then
  echo "   ✓ Port $PORT is open"
else
  echo "   ✗ Port $PORT is closed or filtered"
  exit 1
fi

echo ""
echo "4. Service Response:"
if [ "$PORT" = "80" ] || [ "$PORT" = "3000" ] || [ "$PORT" = "8080" ]; then
  if curl -s -o /dev/null -w "%{http_code}" http://$HOST:$PORT --max-time 5 | grep -q "200\|301\|302"; then
    echo "   ✓ HTTP service responding"
  else
    echo "   ⚠ HTTP service not responding correctly"
  fi
fi

echo ""
echo "=== Diagnostic Complete ==="
EOF

chmod +x netdiag.sh
```

2. Test the diagnostic script:
```bash
# Test working service
./netdiag.sh postgres 5432

# Test web service
./netdiag.sh nginx-web 80

# Test non-existent port
./netdiag.sh postgres 9999
```

## Expected Output

**traceroute google.com:**
```
traceroute to google.com (142.250.X.X), 30 hops max, 60 byte packets
 1  172.X.X.X (172.X.X.X)  0.XXX ms  0.XXX ms  0.XXX ms
 2  * * *
 3  192.168.X.X (192.168.X.X)  X.XXX ms  X.XXX ms  X.XXX ms
...
```

**tcpdump output:**
```
tcpdump: listening on any, link-type LINUX_SLL (Linux cooked), capture size 262144 bytes
12:34:56.789012 IP ubuntu-practice.12345 > postgres.5432: Flags [S], seq 123456789, win 64240
12:34:56.789123 IP postgres.5432 > ubuntu-practice.12345: Flags [S.], seq 987654321, ack 123456790
```

**netdiag.sh output (success):**
```
=== Network Diagnostic Tool ===
Target: postgres:5432

1. DNS Resolution:
   ✓ DNS resolves to: 172.X.X.X

2. Host Reachability:
   ✓ Host is reachable (ping successful)

3. Port Connectivity:
   ✓ Port 5432 is open

=== Diagnostic Complete ===
```

## Verification Steps

- traceroute should show the network path to destinations
- tcpdump should capture and display network packets
- Diagnostic script should correctly identify working and broken services
- Stopped services should be detectable through systematic testing
- DNS issues should be distinguishable from connectivity issues

## Hints

<details>
<summary>Hint 1: Understanding Traceroute</summary>

Traceroute shows the path packets take to reach a destination:
- Each line is a "hop" (router or gateway)
- Three time measurements show round-trip time
- `* * *` means that hop didn't respond (common, not always a problem)
- High latency at a specific hop indicates where slowness occurs

For Docker containers, you'll typically see very few hops since they're on the same host.
</details>

<details>
<summary>Hint 2: Reading tcpdump Output</summary>

tcpdump output format:
```
timestamp IP source > destination: flags, details
```

Common flags:
- **[S]**: SYN (connection start)
- **[S.]**: SYN-ACK (connection acknowledgment)
- **[.]**: ACK (acknowledgment)
- **[P]**: PSH (push data)
- **[F]**: FIN (connection close)
- **[R]**: RST (connection reset)

The three-way handshake: SYN → SYN-ACK → ACK
</details>

<details>
<summary>Hint 3: Systematic Troubleshooting</summary>

Always troubleshoot in layers (bottom to top):

1. **Physical/Link**: Is the host reachable? (ping)
2. **Network**: Can we route to it? (traceroute)
3. **Transport**: Is the port open? (nc, telnet)
4. **Application**: Is the service responding correctly? (curl, specific client)

This helps isolate where the problem is!
</details>

<details>
<summary>Hint 4: Common Error Messages</summary>

- **Connection refused**: Port is closed, service not running
- **No route to host**: Network unreachable, routing issue
- **Connection timeout**: Firewall blocking or host down
- **Name or service not known**: DNS resolution failed
- **Network is unreachable**: No route to destination network

Each error points to a different layer of the problem!
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

### Complete Solution

**Step 1: Install and use traceroute**
```bash
docker exec -it devops-ubuntu bash
apt-get update && apt-get install -y traceroute mtr tcpdump dnsutils net-tools

# Trace to external host
traceroute google.com
# Shows path through network

# Trace to internal service
traceroute postgres
# Usually just 1-2 hops (same Docker host)

# Use mtr for continuous monitoring
mtr --report --report-cycles 10 google.com
```

**Step 2: Capture traffic with tcpdump**
```bash
# Capture traffic to postgres (run in background)
tcpdump -i any host postgres -n &
TCPDUMP_PID=$!

# Generate traffic
ping -c 3 postgres
curl http://nodejs-api:3000/health

# Stop tcpdump
kill $TCPDUMP_PID

# Capture specific port
tcpdump -i any port 80 -c 10 -n
# In another terminal: curl http://nginx-web:80
```

**Step 3: Diagnose service issues**
```bash
# Test a working service
nc -zv postgres 5432
# Output: Connection succeeded

# Stop a service
exit
docker-compose stop redis

# Try to connect
docker exec -it devops-ubuntu bash
nc -zv redis 6379
# Output: Connection refused or timeout

# Systematic diagnosis:
# 1. DNS works?
nslookup redis  # Should still resolve

# 2. Host reachable?
ping -c 2 redis  # May fail if container stopped

# 3. Port open?
nc -zv redis 6379  # Will fail

# Fix and verify
exit
docker-compose start redis
docker exec -it devops-ubuntu bash
nc -zv redis 6379  # Should work now
```

**Step 4: Use diagnostic script**
```bash
# Create comprehensive diagnostic tool
cat > netdiag.sh << 'EOF'
#!/bin/bash
HOST=$1
PORT=$2

if [ -z "$HOST" ] || [ -z "$PORT" ]; then
  echo "Usage: $0 <host> <port>"
  exit 1
fi

echo "=== Network Diagnostic Tool ==="
echo "Target: $HOST:$PORT"
echo ""

echo "1. DNS Resolution:"
if nslookup $HOST > /dev/null 2>&1; then
  IP=$(dig +short $HOST | head -1)
  echo "   ✓ DNS resolves to: $IP"
else
  echo "   ✗ DNS resolution failed"
  exit 1
fi

echo ""
echo "2. Host Reachability:"
if ping -c 3 -W 2 $HOST > /dev/null 2>&1; then
  echo "   ✓ Host is reachable"
else
  echo "   ⚠ Host not responding to ping"
fi

echo ""
echo "3. Port Connectivity:"
if nc -zv -w 2 $HOST $PORT 2>&1 | grep -q "succeeded"; then
  echo "   ✓ Port $PORT is open"
else
  echo "   ✗ Port $PORT is closed"
  exit 1
fi

echo ""
echo "=== Diagnostic Complete ==="
EOF

chmod +x netdiag.sh

# Test it
./netdiag.sh postgres 5432
./netdiag.sh nginx-web 80
./netdiag.sh redis 6379
```

### Explanation

**Troubleshooting Methodology:**

1. **Layer-by-Layer Approach**:
   - Start at the bottom (can we reach the host?)
   - Move up (can we connect to the port?)
   - End at the top (does the application respond correctly?)

2. **Tools for Each Layer**:
   - **DNS**: nslookup, dig
   - **Network**: ping, traceroute, mtr
   - **Transport**: nc, telnet, netstat
   - **Application**: curl, specific clients

3. **Common Issues**:
   - **Service down**: Port closed, connection refused
   - **Network issue**: Timeout, no route to host
   - **DNS issue**: Name resolution fails
   - **Firewall**: Packets dropped silently

**Understanding tcpdump:**

tcpdump captures raw network packets. Key uses:
- Verify traffic is actually being sent
- See if responses are received
- Identify network-level issues
- Debug protocol problems

**Performance Monitoring:**

- **Latency**: Use ping to measure round-trip time
- **Packet loss**: Check ping statistics
- **Route issues**: Use traceroute to find where delays occur
- **Connection count**: Use netstat to monitor active connections

</details>

## Additional Resources

- [traceroute explained](https://linux.die.net/man/8/traceroute)
- [tcpdump tutorial](https://danielmiessler.com/study/tcpdump/)
- [Network troubleshooting guide](https://www.redhat.com/sysadmin/beginners-guide-network-troubleshooting-linux)
- [TCP/IP troubleshooting](https://www.cisco.com/c/en/us/support/docs/ip/routing-information-protocol-rip/13788-3.html)
- [mtr guide](https://www.linode.com/docs/guides/diagnosing-network-issues-with-mtr/)
