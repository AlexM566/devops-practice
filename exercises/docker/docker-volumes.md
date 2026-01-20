# Docker Volumes: Persisting Data

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Docker basics, understanding of container filesystem

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create and manage Docker volumes for persistent data storage, mount volumes to containers, and understand the difference between named volumes and bind mounts. You'll practice data persistence across container restarts and removals.

## Instructions

### Part 1: Understanding Container Filesystem Ephemeral Nature

1. Run a PostgreSQL container without a volume:
```bash
docker run -d --name temp-db -e POSTGRES_PASSWORD=mysecret postgres:alpine
```

2. Wait a few seconds for the database to initialize, then create a test database:
```bash
docker exec temp-db psql -U postgres -c "CREATE DATABASE testdb;"
```

3. Verify the database exists:
```bash
docker exec temp-db psql -U postgres -c "\l"
```

4. Stop and remove the container:
```bash
docker stop temp-db
docker rm temp-db
```

5. Run a new container with the same name:
```bash
docker run -d --name temp-db -e POSTGRES_PASSWORD=mysecret postgres:alpine
```

6. Check if the database still exists (it won't):
```bash
docker exec temp-db psql -U postgres -c "\l"
```

7. Clean up:
```bash
docker stop temp-db
docker rm temp-db
```

### Part 2: Using Named Volumes

8. Create a named volume:
```bash
docker volume create pgdata
```

9. List volumes:
```bash
docker volume ls
```

10. Inspect the volume:
```bash
docker volume inspect pgdata
```

11. Run PostgreSQL with the named volume:
```bash
docker run -d --name persistent-db \
  -e POSTGRES_PASSWORD=mysecret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:alpine
```

12. Wait for initialization, then create a test database:
```bash
docker exec persistent-db psql -U postgres -c "CREATE DATABASE testdb;"
docker exec persistent-db psql -U postgres -c "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(50));" testdb
docker exec persistent-db psql -U postgres -c "INSERT INTO users (name) VALUES ('Alice'), ('Bob');" testdb
```

13. Verify the data:
```bash
docker exec persistent-db psql -U postgres -c "SELECT * FROM users;" testdb
```

14. Stop and remove the container:
```bash
docker stop persistent-db
docker rm persistent-db
```

15. Run a new container with the same volume:
```bash
docker run -d --name persistent-db \
  -e POSTGRES_PASSWORD=mysecret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:alpine
```

16. Verify the data persisted:
```bash
docker exec persistent-db psql -U postgres -c "SELECT * FROM users;" testdb
```

### Part 3: Using Bind Mounts

17. Create a directory for bind mount:
```bash
mkdir -p ~/docker-volumes-demo
cd ~/docker-volumes-demo
```

18. Create a simple HTML file:
```bash
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Original Content</h1>
    <p>This file is mounted from the host.</p>
</body>
</html>
EOF
```

19. Run nginx with a bind mount:
```bash
docker run -d --name web-server \
  -p 8080:80 \
  -v $(pwd):/usr/share/nginx/html:ro \
  nginx:alpine
```

20. Test the web server:
```bash
curl http://localhost:8080
```

21. Modify the HTML file on the host:
```bash
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Updated Content</h1>
    <p>Changes on the host are immediately reflected in the container!</p>
</body>
</html>
EOF
```

22. Test again to see the changes:
```bash
curl http://localhost:8080
```

### Part 4: Volume Management and Cleanup

23. List all volumes:
```bash
docker volume ls
```

24. Stop and remove containers:
```bash
docker stop web-server persistent-db
docker rm web-server persistent-db
```

25. Remove the named volume:
```bash
docker volume rm pgdata
```

26. Verify the volume is removed:
```bash
docker volume ls
```

27. Clean up dangling volumes (volumes not used by any container):
```bash
docker volume prune
```

## Expected Output

**After creating database in temp container (step 3):**
```
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
 testdb    | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
```

**After recreating container without volume (step 6):**
```
(testdb will NOT be in the list - data was lost)
```

**After querying persistent data (step 13 and 16):**
```
 id | name  
----+-------
  1 | Alice
  2 | Bob
(2 rows)
```

**After testing bind mount (step 20):**
```html
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Original Content</h1>
    <p>This file is mounted from the host.</p>
</body>
</html>
```

**After modifying file (step 22):**
```html
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Updated Content</h1>
    <p>Changes on the host are immediately reflected in the container!</p>
</body>
</html>
```

## Verification Steps

- Data in containers without volumes should be lost when containers are removed
- Data in named volumes should persist across container removals
- Changes to bind-mounted files on the host should be immediately visible in the container
- `docker volume ls` should show created volumes
- After cleanup, volumes should be removed

## Hints

<details>
<summary>Hint 1: Volume vs Bind Mount</summary>

**Named Volumes:**
- Managed by Docker
- Stored in Docker's storage directory
- Best for production data persistence
- Created with `docker volume create` or automatically with `-v volumename:/path`

**Bind Mounts:**
- Mount a host directory/file into container
- Full path required (or use `$(pwd)`)
- Best for development (code, config files)
- Changes on host immediately reflected in container
</details>

<details>
<summary>Hint 2: Database Not Ready</summary>

If you get "database system is starting up" error, wait a few seconds for PostgreSQL to initialize:
```bash
docker logs persistent-db
```

Wait until you see "database system is ready to accept connections".
</details>

<details>
<summary>Hint 3: Permission Denied with Bind Mounts</summary>

If you get permission errors with bind mounts, check:
1. The host directory exists and is readable
2. Use absolute paths or `$(pwd)` for current directory
3. On Linux, you may need to adjust SELinux settings or use `:z` flag:
```bash
-v $(pwd):/usr/share/nginx/html:ro,z
```
</details>

<details>
<summary>Hint 4: Read-Only Mounts</summary>

The `:ro` flag makes the mount read-only inside the container. This is a security best practice when the container doesn't need to modify the files. Remove `:ro` if you need write access.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Part 1: Demonstrate ephemeral nature
docker run -d --name temp-db -e POSTGRES_PASSWORD=mysecret postgres:alpine
sleep 10  # Wait for initialization
docker exec temp-db psql -U postgres -c "CREATE DATABASE testdb;"
docker exec temp-db psql -U postgres -c "\l"
docker stop temp-db
docker rm temp-db
docker run -d --name temp-db -e POSTGRES_PASSWORD=mysecret postgres:alpine
sleep 10
docker exec temp-db psql -U postgres -c "\l"  # testdb is gone!
docker stop temp-db
docker rm temp-db

# Part 2: Named volumes for persistence
docker volume create pgdata
docker volume ls
docker volume inspect pgdata

docker run -d --name persistent-db \
  -e POSTGRES_PASSWORD=mysecret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:alpine

sleep 10
docker exec persistent-db psql -U postgres -c "CREATE DATABASE testdb;"
docker exec persistent-db psql -U postgres -c "CREATE TABLE users (id SERIAL PRIMARY KEY, name VARCHAR(50));" testdb
docker exec persistent-db psql -U postgres -c "INSERT INTO users (name) VALUES ('Alice'), ('Bob');" testdb
docker exec persistent-db psql -U postgres -c "SELECT * FROM users;" testdb

docker stop persistent-db
docker rm persistent-db

docker run -d --name persistent-db \
  -e POSTGRES_PASSWORD=mysecret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:alpine

sleep 5
docker exec persistent-db psql -U postgres -c "SELECT * FROM users;" testdb  # Data persisted!

# Part 3: Bind mounts
mkdir -p ~/docker-volumes-demo
cd ~/docker-volumes-demo

cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Original Content</h1>
    <p>This file is mounted from the host.</p>
</body>
</html>
EOF

docker run -d --name web-server \
  -p 8080:80 \
  -v $(pwd):/usr/share/nginx/html:ro \
  nginx:alpine

curl http://localhost:8080

cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>Bind Mount Demo</title></head>
<body>
    <h1>Updated Content</h1>
    <p>Changes on the host are immediately reflected in the container!</p>
</body>
</html>
EOF

curl http://localhost:8080  # See updated content!

# Part 4: Cleanup
docker volume ls
docker stop web-server persistent-db
docker rm web-server persistent-db
docker volume rm pgdata
docker volume ls
docker volume prune -f
```

**Explanation:**
- Container filesystems are ephemeral - data is lost when containers are removed
- Named volumes persist data independently of container lifecycle
- Bind mounts link host directories/files to container paths
- `-v volumename:/container/path` creates/uses a named volume
- `-v /host/path:/container/path` creates a bind mount
- `:ro` makes mounts read-only for security
- `docker volume prune` removes unused volumes to free space
- Always use volumes for production databases and stateful applications
</details>

## Additional Resources

- [Docker volumes documentation](https://docs.docker.com/storage/volumes/)
- [Bind mounts documentation](https://docs.docker.com/storage/bind-mounts/)
- [Storage overview](https://docs.docker.com/storage/)
