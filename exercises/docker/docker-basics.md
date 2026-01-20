# Docker Basics: Running Containers, Executing Commands, and Viewing Logs

**Difficulty:** Beginner
**Estimated Time:** 20 minutes
**Prerequisites:** Docker installed and running

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn the fundamental Docker commands for running containers, executing commands inside containers, and viewing container logs. These are the essential skills you'll use daily when working with Docker.

## Instructions

### Part 1: Running Your First Container

1. Run a simple container that prints a message:
```bash
docker run hello-world
```

2. Run an nginx container in detached mode (background):
```bash
docker run -d --name my-nginx -p 8080:80 nginx:alpine
```

3. List running containers:
```bash
docker ps
```

4. Test that nginx is running:
```bash
curl http://localhost:8080
```

### Part 2: Executing Commands in Containers

5. Execute a command inside the running container:
```bash
docker exec my-nginx cat /etc/nginx/nginx.conf
```

6. Start an interactive shell inside the container:
```bash
docker exec -it my-nginx /bin/sh
```

7. Inside the container, explore the filesystem:
```bash
ls -la /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html
exit
```

### Part 3: Viewing Container Logs

8. View the container logs:
```bash
docker logs my-nginx
```

9. Follow the logs in real-time (press Ctrl+C to stop):
```bash
docker logs -f my-nginx
```

10. Generate some log entries by making requests:
```bash
curl http://localhost:8080
curl http://localhost:8080/nonexistent
```

11. View the last 5 lines of logs:
```bash
docker logs --tail 5 my-nginx
```

### Part 4: Container Lifecycle

12. Stop the container:
```bash
docker stop my-nginx
```

13. List all containers (including stopped):
```bash
docker ps -a
```

14. Start the container again:
```bash
docker start my-nginx
```

15. Restart the container:
```bash
docker restart my-nginx
```

16. Stop and remove the container:
```bash
docker stop my-nginx
docker rm my-nginx
```

### Part 5: Running Containers with Options

17. Run a container that automatically removes itself when stopped:
```bash
docker run -d --rm --name temp-nginx -p 8081:80 nginx:alpine
```

18. Run a container with environment variables:
```bash
docker run -d --name env-test -e MY_VAR="Hello Docker" alpine sleep 300
docker exec env-test env | grep MY_VAR
```

19. Clean up:
```bash
docker stop temp-nginx env-test
docker rm env-test
```

## Expected Output

**After running hello-world (step 1):**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.
...
```

**After listing containers (step 3):**
```
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                  NAMES
abc123def456   nginx:alpine   "/docker-entrypoint.…"   10 seconds ago   Up 9 seconds    0.0.0.0:8080->80/tcp   my-nginx
```

**After curl (step 4):**
```html
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
```

**After viewing logs (step 8):**
```
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
...
```

**After checking environment variable (step 18):**
```
MY_VAR=Hello Docker
```

## Verification Steps

- `docker ps` shows your running containers
- `curl localhost:8080` returns the nginx welcome page
- `docker logs` shows access logs after making requests
- `docker ps -a` shows both running and stopped containers
- Environment variables are accessible inside the container

## Hints

<details>
<summary>Hint 1: Container Won't Start</summary>

If a container fails to start, check if the port is already in use:
```bash
docker ps -a
lsof -i :8080
```

You may need to use a different port or stop the conflicting service.
</details>

<details>
<summary>Hint 2: Interactive Shell Not Working</summary>

The `-it` flags are required for interactive sessions:
- `-i` keeps STDIN open
- `-t` allocates a pseudo-TTY

Some minimal images use `/bin/sh` instead of `/bin/bash`.
</details>

<details>
<summary>Hint 3: Container Exits Immediately</summary>

Containers exit when their main process completes. For containers to stay running, they need a long-running process. That's why we use:
- `nginx` (runs a web server)
- `sleep 300` (sleeps for 300 seconds)
- `-d` flag for detached mode
</details>

<details>
<summary>Hint 4: Cannot Remove Container</summary>

You cannot remove a running container. Stop it first:
```bash
docker stop container-name
docker rm container-name
```

Or force remove:
```bash
docker rm -f container-name
```
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Part 1: Running containers
docker run hello-world
docker run -d --name my-nginx -p 8080:80 nginx:alpine
docker ps
curl http://localhost:8080

# Part 2: Executing commands
docker exec my-nginx cat /etc/nginx/nginx.conf
docker exec -it my-nginx /bin/sh
# Inside container:
ls -la /usr/share/nginx/html/
cat /usr/share/nginx/html/index.html
exit

# Part 3: Viewing logs
docker logs my-nginx
docker logs -f my-nginx  # Ctrl+C to stop
curl http://localhost:8080
curl http://localhost:8080/nonexistent
docker logs --tail 5 my-nginx

# Part 4: Container lifecycle
docker stop my-nginx
docker ps -a
docker start my-nginx
docker restart my-nginx
docker stop my-nginx
docker rm my-nginx

# Part 5: Running with options
docker run -d --rm --name temp-nginx -p 8081:80 nginx:alpine
docker run -d --name env-test -e MY_VAR="Hello Docker" alpine sleep 300
docker exec env-test env | grep MY_VAR
docker stop temp-nginx env-test
docker rm env-test
```

**Key Concepts:**
- `docker run` creates and starts a new container
- `-d` runs the container in detached (background) mode
- `--name` assigns a name to the container
- `-p host:container` maps ports between host and container
- `docker exec` runs commands in a running container
- `-it` enables interactive terminal access
- `docker logs` shows container output
- `--rm` automatically removes the container when it stops
- `-e` sets environment variables
</details>

## Additional Resources

- [Docker run reference](https://docs.docker.com/engine/reference/run/)
- [Docker exec reference](https://docs.docker.com/engine/reference/commandline/exec/)
- [Docker logs reference](https://docs.docker.com/engine/reference/commandline/logs/)
- [Docker getting started guide](https://docs.docker.com/get-started/)
