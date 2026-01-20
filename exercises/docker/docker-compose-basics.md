# Docker Compose Basics: Multi-Service Applications

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** Docker basics, YAML syntax, understanding of multi-tier applications

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to define and manage multi-container applications using Docker Compose. You'll write docker-compose.yml files, understand service definitions, networking, volumes, and environment variables. By the end, you'll be able to orchestrate complex multi-service applications with a single command.

## Instructions

### Part 1: Simple Single-Service Compose File

1. Create a project directory:
```bash
mkdir compose-demo
cd compose-demo
```

2. Create a simple docker-compose.yml:
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    container_name: simple-web
EOF
```

3. Start the service:
```bash
docker-compose up -d
```

4. Verify the service is running:
```bash
docker-compose ps
```

5. Test the web server:
```bash
curl http://localhost:8080
```

6. View logs:
```bash
docker-compose logs web
```

7. Stop and remove:
```bash
docker-compose down
```

### Part 2: Multi-Service Application with Custom Network

8. Create a more complex docker-compose.yml:
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - frontend
    depends_on:
      - api

  api:
    image: node:alpine
    command: sh -c "echo 'API Server' && sleep 3600"
    networks:
      - frontend
      - backend
    depends_on:
      - db

  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    networks:
      - backend
    volumes:
      - db-data:/var/lib/postgresql/data

networks:
  frontend:
  backend:

volumes:
  db-data:
EOF
```

9. Start all services:
```bash
docker-compose up -d
```

10. Check the status of all services:
```bash
docker-compose ps
```

11. Verify the networks were created:
```bash
docker network ls | grep compose-demo
```

12. Test inter-service communication:
```bash
docker-compose exec web ping -c 3 api
docker-compose exec api ping -c 3 db
```

13. Try to ping db from web (should fail - different networks):
```bash
docker-compose exec web ping -c 3 db
```

14. View logs from all services:
```bash
docker-compose logs
```

15. View logs from a specific service:
```bash
docker-compose logs db
```

### Part 3: Building Custom Images with Compose

16. Create a simple Node.js application:
```bash
cat > app.js << 'EOF'
const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    message: 'Hello from Docker Compose!',
    timestamp: new Date().toISOString()
  }));
});

server.listen(3000, () => {
  console.log('Server running on port 3000');
});
EOF
```

17. Create a Dockerfile:
```bash
cat > Dockerfile << 'EOF'
FROM node:alpine
WORKDIR /app
COPY app.js .
EXPOSE 3000
CMD ["node", "app.js"]
EOF
```

18. Update docker-compose.yml to build the custom image:
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
    networks:
      - frontend
    depends_on:
      - api

  api:
    build: .
    ports:
      - "3000:3000"
    networks:
      - frontend
      - backend
    depends_on:
      - db
    environment:
      - NODE_ENV=development

  db:
    image: postgres:alpine
    environment:
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: myapp
    networks:
      - backend
    volumes:
      - db-data:/var/lib/postgresql/data

networks:
  frontend:
  backend:

volumes:
  db-data:
EOF
```

19. Build and start services:
```bash
docker-compose up -d --build
```

20. Test the custom API:
```bash
curl http://localhost:3000
```

21. View API logs:
```bash
docker-compose logs -f api
```

### Part 4: Scaling Services

22. Scale the API service to 3 instances:
```bash
docker-compose up -d --scale api=3
```

23. Check the running instances:
```bash
docker-compose ps
```

24. View logs from all API instances:
```bash
docker-compose logs api
```

### Part 5: Environment Variables and Configuration

25. Create an environment file:
```bash
cat > .env << 'EOF'
POSTGRES_USER=admin
POSTGRES_PASSWORD=supersecret
POSTGRES_DB=production_db
API_PORT=3000
WEB_PORT=8080
EOF
```

26. Update docker-compose.yml to use environment variables:
```bash
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT}:80"
    networks:
      - frontend
    depends_on:
      - api

  api:
    build: .
    ports:
      - "${API_PORT}:3000"
    networks:
      - frontend
      - backend
    depends_on:
      - db
    environment:
      - NODE_ENV=production
      - DB_HOST=db
      - DB_USER=${POSTGRES_USER}
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_NAME=${POSTGRES_DB}

  db:
    image: postgres:alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    networks:
      - backend
    volumes:
      - db-data:/var/lib/postgresql/data

networks:
  frontend:
  backend:

volumes:
  db-data:
EOF
```

27. Restart with new configuration:
```bash
docker-compose down
docker-compose up -d
```

28. Verify environment variables are set:
```bash
docker-compose exec db env | grep POSTGRES
```

### Part 6: Managing the Application Lifecycle

29. Stop all services without removing containers:
```bash
docker-compose stop
```

30. Start stopped services:
```bash
docker-compose start
```

31. Restart a specific service:
```bash
docker-compose restart api
```

32. Remove stopped containers:
```bash
docker-compose rm -f
```

33. Stop and remove everything (containers, networks, volumes):
```bash
docker-compose down -v
```

34. Verify cleanup:
```bash
docker-compose ps
docker volume ls | grep compose-demo
```

## Expected Output

**After starting services (step 10):**
```
    Name                   Command               State           Ports         
-------------------------------------------------------------------------------
compose-demo-api-1    sh -c echo 'API Server' && ...   Up                        
compose-demo-db-1     docker-entrypoint.sh postgres    Up      5432/tcp          
compose-demo-web-1    /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8080->80/tcp
```

**After testing custom API (step 20):**
```json
{
  "message": "Hello from Docker Compose!",
  "timestamp": "2026-01-19T10:30:45.123Z"
}
```

**After scaling services (step 23):**
```
    Name                   Command               State           Ports         
-------------------------------------------------------------------------------
compose-demo-api-1    node app.js                      Up      0.0.0.0:3000->3000/tcp
compose-demo-api-2    node app.js                      Up      3000/tcp
compose-demo-api-3    node app.js                      Up      3000/tcp
compose-demo-db-1     docker-entrypoint.sh postgres    Up      5432/tcp
compose-demo-web-1    /docker-entrypoint.sh ngin ...   Up      0.0.0.0:8080->80/tcp
```

## Verification Steps

- `docker-compose ps` should show all services as "Up"
- Services should be able to communicate using service names
- Networks should isolate services appropriately
- Volumes should persist data across container restarts
- Environment variables should be properly injected
- Scaling should create multiple instances of a service
- `docker-compose down -v` should remove all resources

## Hints

<details>
<summary>Hint 1: Service Dependencies</summary>

The `depends_on` directive controls startup order but doesn't wait for services to be "ready". For example, the API might start before the database is ready to accept connections.

For production, implement health checks and retry logic in your application code.
</details>

<details>
<summary>Hint 2: Network Isolation</summary>

Services can only communicate if they're on the same network. In the example:
- `web` and `api` are on `frontend`
- `api` and `db` are on `backend`
- `web` cannot reach `db` directly (network isolation)

This is a security best practice for multi-tier applications.
</details>

<details>
<summary>Hint 3: Volume Persistence</summary>

Named volumes persist data even after `docker-compose down`. To remove volumes, use:
```bash
docker-compose down -v
```

Without `-v`, volumes remain and data persists across deployments.
</details>

<details>
<summary>Hint 4: Building Images</summary>

When you change the Dockerfile or application code, rebuild with:
```bash
docker-compose up -d --build
```

Or build without starting:
```bash
docker-compose build
```
</details>

<details>
<summary>Hint 5: Environment Variables</summary>

Docker Compose reads `.env` files automatically. You can also:
- Use `env_file` directive to specify custom env files
- Set environment variables directly in the compose file
- Pass environment variables from the host shell

Priority: Shell > Compose file > .env file
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

The complete docker-compose.yml for a production-ready multi-service application:

```yaml
version: '3.8'

services:
  web:
    image: nginx:alpine
    ports:
      - "${WEB_PORT:-8080}:80"
    networks:
      - frontend
    depends_on:
      - api
    restart: unless-stopped

  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "${API_PORT:-3000}:3000"
    networks:
      - frontend
      - backend
    depends_on:
      - db
    environment:
      - NODE_ENV=${NODE_ENV:-production}
      - DB_HOST=db
      - DB_USER=${POSTGRES_USER:-postgres}
      - DB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_NAME=${POSTGRES_DB:-myapp}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000"]
      interval: 30s
      timeout: 10s
      retries: 3

  db:
    image: postgres:alpine
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-postgres}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB:-myapp}
    networks:
      - backend
    volumes:
      - db-data:/var/lib/postgresql/data
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge

volumes:
  db-data:
    driver: local
```

**Key Concepts:**
- **version**: Compose file format version
- **services**: Define containers to run
- **networks**: Create isolated network segments
- **volumes**: Persist data across container lifecycles
- **depends_on**: Control startup order
- **environment**: Set environment variables
- **ports**: Expose ports to host
- **build**: Build custom images
- **restart**: Restart policy for containers
- **healthcheck**: Monitor service health

**Common Commands:**
```bash
docker-compose up -d          # Start in detached mode
docker-compose down           # Stop and remove containers
docker-compose down -v        # Also remove volumes
docker-compose ps             # List containers
docker-compose logs -f        # Follow logs
docker-compose exec <service> <command>  # Execute command
docker-compose build          # Build/rebuild images
docker-compose up -d --build  # Rebuild and start
docker-compose scale <service>=<n>  # Scale service
docker-compose restart <service>    # Restart service
```
</details>

## Additional Resources

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)
- [Compose CLI reference](https://docs.docker.com/compose/reference/)
- [Best practices for Compose](https://docs.docker.com/compose/production/)
