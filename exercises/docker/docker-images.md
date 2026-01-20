# Docker Images: Building, Tagging, and Managing Images

**Difficulty:** Beginner
**Estimated Time:** 25 minutes
**Prerequisites:** Docker basics, understanding of Dockerfile syntax

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to build custom Docker images from Dockerfiles, tag images with meaningful names and versions, and understand image management. You'll create a simple web application image and practice image operations.

## Instructions

### Part 1: Creating a Simple Application

1. Create a new directory for your project:
```bash
mkdir my-web-app
cd my-web-app
```

2. Create a simple HTML file:
```bash
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Custom App</title>
</head>
<body>
    <h1>Hello from my custom Docker image!</h1>
    <p>This is a simple web application running in a container.</p>
</body>
</html>
EOF
```

### Part 2: Building a Custom Image

3. Create a Dockerfile:
```bash
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF
```

4. Build the image with a tag:
```bash
docker build -t my-web-app:v1.0 .
```

5. List your images to verify the build:
```bash
docker images
```

6. Inspect the image details:
```bash
docker inspect my-web-app:v1.0
```

### Part 3: Tagging Images

7. Create an additional tag for the same image:
```bash
docker tag my-web-app:v1.0 my-web-app:latest
```

8. Create a tag with your username (replace 'yourusername'):
```bash
docker tag my-web-app:v1.0 yourusername/my-web-app:v1.0
```

9. List images again to see all tags:
```bash
docker images | grep my-web-app
```

### Part 4: Running Your Custom Image

10. Run a container from your custom image:
```bash
docker run -d --name my-app -p 8080:80 my-web-app:v1.0
```

11. Test your application:
```bash
curl http://localhost:8080
```

12. Stop and remove the container:
```bash
docker stop my-app
docker rm my-app
```

### Part 5: Image Management

13. View image history to see layers:
```bash
docker history my-web-app:v1.0
```

14. Remove a specific tag:
```bash
docker rmi my-web-app:latest
```

15. List images to verify the tag was removed:
```bash
docker images | grep my-web-app
```

16. Clean up remaining images:
```bash
docker rmi my-web-app:v1.0 yourusername/my-web-app:v1.0
```

## Expected Output

**After building the image (step 4):**
```
Sending build context to Docker daemon  3.072kB
Step 1/3 : FROM nginx:alpine
 ---> abc123def456
Step 2/3 : COPY index.html /usr/share/nginx/html/index.html
 ---> 789ghi012jkl
Step 3/3 : EXPOSE 80
 ---> Running in mno345pqr678
 ---> stu901vwx234
Successfully built stu901vwx234
Successfully tagged my-web-app:v1.0
```

**After listing images (step 5):**
```
REPOSITORY    TAG       IMAGE ID       CREATED          SIZE
my-web-app    v1.0      stu901vwx234   10 seconds ago   23.5MB
nginx         alpine    abc123def456   2 weeks ago      23.5MB
```

**After testing the application (step 11):**
```html
<!DOCTYPE html>
<html>
<head>
    <title>My Custom App</title>
</head>
<body>
    <h1>Hello from my custom Docker image!</h1>
    <p>This is a simple web application running in a container.</p>
</body>
</html>
```

**After viewing history (step 13):**
```
IMAGE          CREATED          CREATED BY                                      SIZE
stu901vwx234   2 minutes ago    /bin/sh -c #(nop) EXPOSE 80                     0B
789ghi012jkl   2 minutes ago    /bin/sh -c #(nop) COPY file:abc123... in /u…   500B
abc123def456   2 weeks ago      /bin/sh -c #(nop)  CMD ["nginx" "-g" "daemon…   0B
```

## Verification Steps

- `docker images` should show your custom image with the correct tag
- Running a container from your image should serve your custom HTML
- Multiple tags should point to the same IMAGE ID
- After removing tags, they should no longer appear in `docker images`
- Image history should show the layers from your Dockerfile

## Hints

<details>
<summary>Hint 1: Build Context Error</summary>

If you get "unable to prepare context" error, make sure you're in the directory containing the Dockerfile:
```bash
pwd
ls -la
```

The `.` at the end of `docker build` refers to the current directory as the build context.
</details>

<details>
<summary>Hint 2: Understanding Image Tags</summary>

Tags are just labels pointing to the same image. Multiple tags can reference the same IMAGE ID. When you create a new tag, you're not creating a new image, just a new reference to the existing image.

Check IMAGE IDs to verify:
```bash
docker images | grep my-web-app
```
</details>

<details>
<summary>Hint 3: Cannot Remove Image</summary>

If you get "image is being used by running container" error, you need to stop and remove containers using that image first:
```bash
docker ps -a
docker stop <container-name>
docker rm <container-name>
```

Then try removing the image again.
</details>

<details>
<summary>Hint 4: Push to Registry (Optional)</summary>

To actually push to Docker Hub, you need to:
1. Create an account at hub.docker.com
2. Login: `docker login`
3. Push: `docker push yourusername/my-web-app:v1.0`

Note: This exercise doesn't require actually pushing to a registry.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Here's the complete sequence of commands:

```bash
# Create project directory
mkdir my-web-app
cd my-web-app

# Create HTML file
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Custom App</title>
</head>
<body>
    <h1>Hello from my custom Docker image!</h1>
    <p>This is a simple web application running in a container.</p>
</body>
</html>
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
EOF

# Build the image
docker build -t my-web-app:v1.0 .

# List images
docker images

# Inspect the image
docker inspect my-web-app:v1.0

# Create additional tags
docker tag my-web-app:v1.0 my-web-app:latest
docker tag my-web-app:v1.0 yourusername/my-web-app:v1.0

# List images with tags
docker images | grep my-web-app

# Run container from custom image
docker run -d --name my-app -p 8080:80 my-web-app:v1.0

# Test the application
curl http://localhost:8080

# Clean up container
docker stop my-app
docker rm my-app

# View image history
docker history my-web-app:v1.0

# Remove tags
docker rmi my-web-app:latest
docker images | grep my-web-app

# Clean up remaining images
docker rmi my-web-app:v1.0 yourusername/my-web-app:v1.0
```

**Explanation:**
- `FROM` specifies the base image (nginx:alpine is small and efficient)
- `COPY` adds your custom HTML file to the image
- `EXPOSE` documents which port the container listens on
- `docker build -t` builds and tags the image in one command
- `docker tag` creates additional references to the same image
- `docker history` shows the layers that make up the image
- `docker rmi` removes image tags/references
- An image is only deleted when all tags referencing it are removed
</details>

## Additional Resources

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Docker build reference](https://docs.docker.com/engine/reference/commandline/build/)
- [Docker tag reference](https://docs.docker.com/engine/reference/commandline/tag/)
- [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
