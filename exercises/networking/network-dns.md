# Network DNS: Hostname Resolution

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Basic networking knowledge, network-basics.md

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to use DNS tools to resolve hostnames, query DNS records, and understand how Docker's internal DNS works. You'll use dig and nslookup to investigate DNS resolution for both internal services and external domains.

## Instructions

### Part 1: Install DNS Tools

1. Access the Ubuntu practice container:
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
```

2. Install DNS utilities (dig and nslookup):
```bash
apt-get update && apt-get install -y dnsutils
```

### Part 2: Resolve Internal Service Names

1. Use nslookup to resolve the postgres service:
```bash
nslookup postgres
```

2. Use dig to get more detailed information about the postgres service:
```bash
dig postgres
```

3. Resolve other internal services:
```bash
nslookup redis
nslookup nodejs-api
nslookup nginx-web
```

4. Find the DNS server being used:
```bash
cat /etc/resolv.conf
```

### Part 3: Resolve External Domains

1. Use nslookup to resolve an external domain:
```bash
nslookup google.com
```

2. Use dig to get detailed DNS information:
```bash
dig google.com
```

3. Query specific DNS record types:
```bash
# Query A records (IPv4 addresses)
dig google.com A

# Query AAAA records (IPv6 addresses)
dig google.com AAAA

# Query MX records (mail servers)
dig google.com MX

# Query NS records (nameservers)
dig google.com NS
```

4. Use a specific DNS server (Google's public DNS):
```bash
dig @8.8.8.8 google.com
```

### Part 4: Reverse DNS Lookup

1. Get the IP address of a service:
```bash
ping -c 1 postgres | head -1
```

2. Perform a reverse DNS lookup on that IP:
```bash
nslookup <IP_ADDRESS>
```

3. Try reverse lookup on an external IP:
```bash
nslookup 8.8.8.8
```

## Expected Output

**nslookup postgres:**
```
Server:		127.0.0.11
Address:	127.0.0.11#53

Non-authoritative answer:
Name:	postgres
Address: 172.X.X.X
```

**dig postgres:**
```
; <<>> DiG 9.X.X <<>> postgres
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: XXXXX
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;postgres.			IN	A

;; ANSWER SECTION:
postgres.		600	IN	A	172.X.X.X

;; Query time: X msec
;; SERVER: 127.0.0.11#53(127.0.0.11)
;; WHEN: ...
;; MSG SIZE  rcvd: XX
```

**dig google.com MX:**
```
;; ANSWER SECTION:
google.com.		XXX	IN	MX	10 smtp.google.com.
```

**/etc/resolv.conf:**
```
nameserver 127.0.0.11
options ndots:0
```

## Verification Steps

- nslookup should resolve service names to internal IP addresses
- dig should show the Docker DNS server (127.0.0.11) as the resolver
- External domains should resolve to public IP addresses
- Different record types (A, MX, NS) should return appropriate data
- Reverse lookups should work for both internal and external IPs

## Hints

<details>
<summary>Hint 1: Installing DNS Tools</summary>

If dnsutils is not available, the package might have a different name:
```bash
# For Alpine Linux
apk add bind-tools

# For Ubuntu/Debian
apt-get install -y dnsutils
```
</details>

<details>
<summary>Hint 2: Docker's Internal DNS</summary>

Docker runs an embedded DNS server at 127.0.0.11 inside each container. This DNS server:
- Resolves service names to container IPs
- Forwards external queries to the host's DNS
- Updates automatically when containers start/stop
</details>

<details>
<summary>Hint 3: Understanding dig Output</summary>

Key sections in dig output:
- **QUESTION SECTION**: What you asked for
- **ANSWER SECTION**: The DNS response
- **AUTHORITY SECTION**: Authoritative nameservers
- **ADDITIONAL SECTION**: Extra information
- **Query time**: How long the lookup took
- **SERVER**: Which DNS server answered
</details>

<details>
<summary>Hint 4: DNS Record Types</summary>

Common DNS record types:
- **A**: IPv4 address
- **AAAA**: IPv6 address
- **CNAME**: Canonical name (alias)
- **MX**: Mail exchange server
- **NS**: Nameserver
- **TXT**: Text records (often used for verification)
- **PTR**: Pointer record (for reverse DNS)
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

### Complete Solution

**Step 1: Access container and install tools**
```bash
docker exec -it devops-playground-ubuntu-practice-1 bash
apt-get update && apt-get install -y dnsutils
```

**Step 2: Resolve internal services**
```bash
# Basic resolution
nslookup postgres
# Shows: Server: 127.0.0.11, Address: 172.X.X.X

# Detailed resolution
dig postgres
# Shows full DNS query/response with Docker's DNS server

# Resolve multiple services
nslookup redis
nslookup nodejs-api
nslookup nginx-web

# Check DNS configuration
cat /etc/resolv.conf
# Shows: nameserver 127.0.0.11
```

**Step 3: Resolve external domains**
```bash
# Basic external resolution
nslookup google.com
dig google.com

# Query specific record types
dig google.com A      # IPv4 addresses
dig google.com AAAA   # IPv6 addresses
dig google.com MX     # Mail servers
dig google.com NS     # Nameservers

# Use specific DNS server
dig @8.8.8.8 google.com
# Queries Google's public DNS directly
```

**Step 4: Reverse DNS lookups**
```bash
# Get IP of postgres
POSTGRES_IP=$(dig +short postgres)
echo $POSTGRES_IP

# Reverse lookup (may not have PTR record)
nslookup $POSTGRES_IP

# Reverse lookup of Google DNS
nslookup 8.8.8.8
# Shows: dns.google
```

### Explanation

**How Docker DNS Works:**

1. **Embedded DNS Server**: Docker runs a DNS server at 127.0.0.11 inside each container. This is visible in `/etc/resolv.conf`.

2. **Service Name Resolution**: When you query a service name like `postgres`, Docker's DNS:
   - Checks if it's a service in the same network
   - Returns the container's IP address
   - Updates automatically when containers restart

3. **External Resolution**: For external domains, Docker's DNS:
   - Forwards the query to the host's DNS servers
   - Caches responses for performance
   - Returns the result to the container

4. **Network Isolation**: DNS resolution respects Docker networks. You can only resolve services on networks your container is connected to.

**Understanding dig Output:**

- **status: NOERROR**: Query succeeded
- **ANSWER: 1**: One answer returned
- **TTL (600)**: Time to live in seconds
- **IN A**: Internet Address record
- **Query time**: Milliseconds to resolve

**DNS Record Types:**

- **A records**: Map hostnames to IPv4 addresses
- **MX records**: Specify mail servers for a domain
- **NS records**: Identify authoritative nameservers
- **CNAME records**: Create aliases for hostnames

</details>

## Additional Resources

- [Docker Embedded DNS](https://docs.docker.com/config/containers/container-networking/#dns-services)
- [dig command manual](https://linux.die.net/man/1/dig)
- [nslookup guide](https://linux.die.net/man/1/nslookup)
- [DNS Record Types](https://www.cloudflare.com/learning/dns/dns-records/)
- [How DNS Works](https://www.cloudflare.com/learning/dns/what-is-dns/)
