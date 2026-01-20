# Docker Networking: Custom Networks and Container Communication

**Difficulty:** Intermediate
**Estimated Time:** 30 minutes
**Prerequisites:** Docker basics, understanding of networking concepts

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create custom Docker networks, connect containers to networks, and test inter-container communication. You'll understand different network drivers, network isolation, and how containers discover each other using DNS.

## Instructions

### Part 1: Understanding Default Bridge Network

1. Run two containers on the default bridge network:
```bash
docker run -d --name container1 alpine sleep 3600
docker run -d --name container2 alpine sleep 3600
```

2. Inspect the default bridge network:
```bash
docker network inspect bridge
```

3. Get the IP address of container1:
```bash
docker inspect container1 | grep IPAddress
```

4. Try to ping container1 from container2 using its name (this will fail):
```bash
docker exec container2 ping -c 3 container1
```

5. Try to ping using the IP address (this will work):
```bash
docker exec container2 ping -c 3 <container1-ip-address>
```

6. Clean up:
```bash
docker stop container1 container2
docker rm container1 container2
```

### Part 2: Creating Custom Bridge Networks

7. Create a custom bridge network:
```bash
docker network create my-network
```

8. List all networks:
```bash
docker network ls
```

9. Inspect your custom network:
```bash
docker network inspect my-network
```

10. Run containers on the custom network:
```bash
docker run -d --name app1 --network my-network alpine sleep 3600
docker run -d --name app2 --network my-network alpine sleep 3600
```

11. Test DNS-based communication (this will work):
```bash
docker exec app1 ping -c 3 app2
docker exec app2 ping -c 3 app1
```

### Part 3: Multi-Network Setup

12. Create a second network:
```bash
docker network create frontend-network
docker network create backend-network
```

13. Run containers on different networks:
```bash
docker run -d --name web --network frontend-network alpine sleep 3600
docker run -d --name api --network backend-network alpine sleep 3600
docker run -d --name db --network backend-network alpine sleep 3600
```

14. Try to ping from web to api (this will fail - different networks):
```bash
docker exec web ping -c 3 api
```

15. Connect the api container to both networks:
```bash
docker network connect frontend-network api
```

16. Now try to ping from web to api (this will work):
```bash
docker exec web ping -c 3 api
```

17. Verify api is on both networks:
```bash
docker inspect api | grep -A 10 Networks
```

18. Test that api can reach db on backend network:
```bash
docker exec api ping -c 3 db
```

19. Verify web still cannot reach db directly:
```bash
docker exec web ping -c 3 db
```

### Part 4: Practical Example - Web Application Stack

20. Create networks for a typical web application:
```bash
docker network create app-frontend
docker network create app-backend
```

21. Run a database container on the backend network:
```bash
docker run -d --name postgres \
  --network app-backend \
  -e POSTGRES_PASSWORD=secret \
  postgres:alpine
```

22. Run an API container connected to both networks:
```bash
docker run -d --name api-server \
  --network app-backend \
  -e DATABASE_URL=postgres://postgres:secret@postgres:5432/postgres \
  alpine sleep 3600
```

23. Connect the API to the frontend network:
```bash
docker network connect app-frontend api-server
```

24. Run a web server on the frontend network:
```bash
docker run -d --name nginx \
  --network app-frontend \
  -p 8080:80 \
  nginx:alpine
```

25. Verify the web server can reach the API:
```bash
docker exec nginx ping -c 3 api-server
```

26. Verify the API can reach the database:
```bash
docker exec api-server ping -c 3 postgres
```

27. Verify the web server cannot reach the database directly:
```bash
docker exec nginx ping -c 3 postgres
```

### Part 5: Network Cleanup

28. Disconnect a container from a network:
```bash
docker network disconnect app-frontend api-server
```

29. Stop and remove all containers:
```bash
docker stop app1 app2 web api db postgres api-server nginx
docker rm app1 app2 web api db postgres api-server nginx
```

30. Remove custom networks:
```bash
docker network rm my-network frontend-network backend-network app-frontend app-backend
```

31. List networks to verify cleanup:
```bash
docker network ls
```

## Expected Output

**After inspecting default bridge (step 2):**
```json
[
    {
        "Name": "bridge",
        "Driver": "bridge",
        "Containers": {
            "abc123...": {
                "Name": "container1",
                "IPv4Address": "172.17.0.2/16"
            },
            "def456...": {
                "Name": "container2",
                "IPv4Address": "172.17.0.3/16"
            }
        }
    }
]
```

**After pinging by name on default bridge (step 4):**
```
ping: bad address 'container1'
```

**After pinging by name on custom network (step 11):**
```
PING app2 (172.18.0.3): 56 data bytes
64 bytes from 172.18.0.3: seq=0 ttl=64 time=0.123 ms
64 bytes from 172.18.0.3: seq=1 ttl=64 time=0.098 ms
64 bytes from 172.18.0.3: seq=2 ttl=64 time=0.105 ms
```

**After connecting api to frontend network (step 16):**
```
PING api (172.19.0.2): 56 data bytes
64 bytes from 172.19.0.2: seq=0 ttl=64 time=0.089 ms
64 bytes from 172.19.0.2: seq=1 ttl=64 time=0.076 ms
64 bytes from 172.19.0.2: seq=2 ttl=64 time=0.082 ms
```

## Verification Steps

- Containers on the default bridge network cannot communicate by name
- Containers on custom bridge networks can communicate by name (DNS)
- Containers on different networks cannot communicate
- A container can be connected to multiple networks
- Network isolation prevents unauthorized access between network segments
- After cleanup, only default networks (bridge, host, none) should remain

## Hints

<details>
<summary>Hint 1: DNS Resolution on Custom Networks</summary>

Custom bridge networks provide automatic DNS resolution between containers. This is why you can use container names instead of IP addresses. The default bridge network does not provide this feature for backward compatibility.

To use DNS on the default bridge, you need to use the `--link` flag (deprecated) or create a custom network.
</details>

<details>
<summary>Hint 2: Network Isolation</summary>

Network isolation is a security feature. Containers on different networks cannot communicate unless explicitly connected. This allows you to:
- Separate frontend from backend
- Isolate databases from public-facing services
- Create DMZ-like architectures
- Implement defense in depth
</details>

<details>
<summary>Hint 3: Multiple Network Connections</summary>

A container can be connected to multiple networks, making it act as a bridge between network segments. This is useful for:
- API gateways that need to access both frontend and backend
- Reverse proxies
- Service meshes
- Monitoring containers that need access to all networks
</details>

<details>
<summary>Hint 4: Network Drivers</summary>

Docker supports several network drivers:
- **bridge**: Default, for single-host networking
- **host**: Container uses host's network stack (no isolation)
- **overlay**: Multi-host networking for Swarm
- **macvlan**: Assign MAC address to container
- **none**: No networking

For most use cases, custom bridge networks are the best choice.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Part 1: Default bridge network
docker run -d --name container1 alpine sleep 3600
docker run -d --name container2 alpine sleep 3600
docker network inspect bridge
docker inspect container1 | grep IPAddress
# Note the IP address, then use it below
docker exec container2 ping -c 3 container1  # Fails
docker exec container2 ping -c 3 172.17.0.2  # Works (use actual IP)
docker stop container1 container2
docker rm container1 container2

# Part 2: Custom bridge network
docker network create my-network
docker network ls
docker network inspect my-network
docker run -d --name app1 --network my-network alpine sleep 3600
docker run -d --name app2 --network my-network alpine sleep 3600
docker exec app1 ping -c 3 app2  # Works with DNS!
docker exec app2 ping -c 3 app1  # Works with DNS!

# Part 3: Multi-network setup
docker network create frontend-network
docker network create backend-network
docker run -d --name web --network frontend-network alpine sleep 3600
docker run -d --name api --network backend-network alpine sleep 3600
docker run -d --name db --network backend-network alpine sleep 3600
docker exec web ping -c 3 api  # Fails - different networks
docker network connect frontend-network api
docker exec web ping -c 3 api  # Works now!
docker inspect api | grep -A 10 Networks
docker exec api ping -c 3 db  # Works - same backend network
docker exec web ping -c 3 db  # Fails - web not on backend network

# Part 4: Practical example
docker network create app-frontend
docker network create app-backend
docker run -d --name postgres \
  --network app-backend \
  -e POSTGRES_PASSWORD=secret \
  postgres:alpine
docker run -d --name api-server \
  --network app-backend \
  -e DATABASE_URL=postgres://postgres:secret@postgres:5432/postgres \
  alpine sleep 3600
docker network connect app-frontend api-server
docker run -d --name nginx \
  --network app-frontend \
  -p 8080:80 \
  nginx:alpine
docker exec nginx ping -c 3 api-server  # Works
docker exec api-server ping -c 3 postgres  # Works
docker exec nginx ping -c 3 postgres  # Fails - isolated!

# Part 5: Cleanup
docker network disconnect app-frontend api-server
docker stop app1 app2 web api db postgres api-server nginx
docker rm app1 app2 web api db postgres api-server nginx
docker network rm my-network frontend-network backend-network app-frontend app-backend
docker network ls
```

**Explanation:**
- Default bridge network doesn't provide DNS resolution
- Custom bridge networks provide automatic DNS between containers
- Network isolation prevents cross-network communication
- `docker network connect` adds a container to an additional network
- Containers can be on multiple networks simultaneously
- This enables secure multi-tier architectures
- Always use custom networks for production applications
- Network isolation is a key security principle
</details>

## Additional Resources

- [Docker networking overview](https://docs.docker.com/network/)
- [Bridge network driver](https://docs.docker.com/network/bridge/)
- [Network commands reference](https://docs.docker.com/engine/reference/commandline/network/)
- [Container networking tutorial](https://docs.docker.com/config/containers/container-networking/)
