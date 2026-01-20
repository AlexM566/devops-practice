# GitHub Actions Artifacts

**Difficulty:** Intermediate
**Estimated Time:** 40 minutes
**Prerequisites:** GitHub Actions basics, understanding of build artifacts

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to produce, upload, and use artifacts in GitHub Actions workflows. Artifacts allow you to persist data between jobs and share files like build outputs, test results, and logs across your workflow.

## Instructions

In this exercise, you'll create a workflow that builds an application, produces artifacts, and then uses those artifacts in a subsequent deployment job.

### Part 1: Create the Artifact Workflow

1. Create a new file called `artifact-workflow.yml` in the `exercises/cicd/pipelines/` directory
2. Define the workflow name as "Build and Deploy with Artifacts"
3. Configure the workflow to trigger on push to the `main` branch

### Part 2: Create the Build Job

1. Add a `build` job that:
   - Creates a `dist/` directory
   - Generates a build artifact (a simple text file simulating compiled code)
   - Creates a `build-info.json` with build metadata
   - "Uploads" the artifact (simulated locally by copying to a shared location)

### Part 3: Create the Test Job

1. Add a `test` job that depends on `build`
2. The test job should:
   - "Download" the build artifact
   - Verify the artifact exists
   - Run simulated tests against the artifact
   - Generate a test report

### Part 4: Create the Deploy Job

1. Add a `deploy` job that depends on both `build` and `test`
2. The deploy job should:
   - Download the build artifact
   - Simulate deployment
   - Output deployment confirmation

## Expected Output

```
=== Running Job: build ===
Step: Create build directory
  ✓ Completed
Step: Build application
  Building application...
  Created dist/app.js
  ✓ Completed
Step: Generate build info
  Build info created: build-info.json
  ✓ Completed
Step: Upload artifact
  Uploading artifact: build-output
  ✓ Completed

=== Running Job: test ===
Step: Download artifact
  Downloading artifact: build-output
  ✓ Completed
Step: Verify artifact
  Artifact verified: dist/app.js exists
  ✓ Completed
Step: Run tests
  Running tests...
  All tests passed!
  ✓ Completed

=== Running Job: deploy ===
Step: Download artifact
  Downloading artifact: build-output
  ✓ Completed
Step: Deploy application
  Deploying to production...
  Deployment successful!
  ✓ Completed

Pipeline completed successfully!
```

## Verification Steps

1. Validate your workflow:
   ```bash
   docker exec devops-cicd cicd-sim validate /pipelines/artifact-workflow.yml
   ```

2. Run the workflow:
   ```bash
   docker exec devops-cicd cicd-sim run --type github /pipelines/artifact-workflow.yml
   ```

3. Verify artifacts are created and passed between jobs

## Hints

<details>
<summary>Hint 1: Simulating Artifact Upload</summary>

In the local simulator, we simulate artifact upload by creating files in a shared location:

```yaml
- name: Upload artifact
  run: |
    mkdir -p /tmp/artifacts/build-output
    cp -r dist/* /tmp/artifacts/build-output/
    echo "Artifact uploaded: build-output"
```
</details>

<details>
<summary>Hint 2: Simulating Artifact Download</summary>

Download is simulated by copying from the shared location:

```yaml
- name: Download artifact
  run: |
    cp -r /tmp/artifacts/build-output/* ./dist/
    echo "Artifact downloaded: build-output"
```
</details>

<details>
<summary>Hint 3: Multiple Job Dependencies</summary>

A job can depend on multiple jobs:

```yaml
deploy:
  needs: [build, test]
```
</details>

<details>
<summary>Hint 4: Real GitHub Actions Syntax</summary>

In real GitHub Actions, you would use:

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/

- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

Create `exercises/cicd/pipelines/artifact-workflow.yml`:

```yaml
name: Build and Deploy with Artifacts

on:
  push:
    branches:
      - main

env:
  ARTIFACT_DIR: /tmp/artifacts

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Create build directory
        run: mkdir -p dist

      - name: Build application
        run: |
          echo "Building application..."
          echo "console.log('Hello from CI/CD!');" > dist/app.js
          echo "export default { version: '1.0.0' };" > dist/config.js
          echo "Created dist/app.js and dist/config.js"

      - name: Generate build info
        run: |
          echo '{
            "version": "1.0.0",
            "build_number": "'"$GITHUB_RUN_NUMBER"'",
            "commit": "'"$GITHUB_SHA"'",
            "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
          }' > dist/build-info.json
          echo "Build info created: build-info.json"
          cat dist/build-info.json

      - name: Upload artifact
        run: |
          mkdir -p $ARTIFACT_DIR/build-output
          cp -r dist/* $ARTIFACT_DIR/build-output/
          echo "Uploading artifact: build-output"
          ls -la $ARTIFACT_DIR/build-output/

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Download artifact
        run: |
          mkdir -p dist
          cp -r $ARTIFACT_DIR/build-output/* dist/
          echo "Downloading artifact: build-output"

      - name: Verify artifact
        run: |
          if [ -f dist/app.js ]; then
            echo "Artifact verified: dist/app.js exists"
            cat dist/app.js
          else
            echo "ERROR: Artifact not found!"
            exit 1
          fi

      - name: Run tests
        run: |
          echo "Running tests..."
          echo "Testing app.js..."
          grep -q "Hello from CI/CD" dist/app.js && echo "✓ App content test passed"
          echo "Testing build-info.json..."
          [ -f dist/build-info.json ] && echo "✓ Build info exists"
          echo "All tests passed!"

      - name: Generate test report
        run: |
          echo "Test Report" > test-report.txt
          echo "===========" >> test-report.txt
          echo "Status: PASSED" >> test-report.txt
          echo "Tests Run: 2" >> test-report.txt
          echo "Tests Passed: 2" >> test-report.txt
          cat test-report.txt

  deploy:
    runs-on: ubuntu-latest
    needs: [build, test]
    steps:
      - name: Download artifact
        run: |
          mkdir -p dist
          cp -r $ARTIFACT_DIR/build-output/* dist/
          echo "Downloading artifact: build-output"

      - name: Verify deployment package
        run: |
          echo "Verifying deployment package..."
          ls -la dist/
          echo "Package verified!"

      - name: Deploy application
        run: |
          echo "Deploying to production..."
          echo "Copying files to server..."
          echo "Restarting services..."
          echo "Deployment successful!"

      - name: Deployment summary
        run: |
          echo "================================"
          echo "DEPLOYMENT SUMMARY"
          echo "================================"
          echo "Environment: production"
          echo "Version: $(cat dist/build-info.json | grep version | head -1)"
          echo "Status: SUCCESS"
          echo "================================"
```

### Explanation

**Artifact Concepts:**
- Artifacts are files produced by one job that need to be used by another
- Common artifacts: compiled code, test results, logs, coverage reports
- In real GitHub Actions, artifacts are stored in GitHub's artifact storage

**Local Simulation:**
- We use `/tmp/artifacts/` as a shared location between jobs
- Upload = copy files to shared location
- Download = copy files from shared location

**Job Dependencies:**
- `needs: build` - test job waits for build to complete
- `needs: [build, test]` - deploy waits for both jobs
- Artifacts are available after the producing job completes

**Environment Variables:**
- `env` at workflow level sets variables for all jobs
- `$ARTIFACT_DIR` is used consistently across jobs

**Real GitHub Actions:**
In production, you would use:
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: dist/
    retention-days: 5

- uses: actions/download-artifact@v4
  with:
    name: build-output
    path: dist/
```

**Best Practices:**
1. Use meaningful artifact names
2. Set retention periods for artifacts
3. Verify artifacts after download
4. Include metadata (build info, version) in artifacts

</details>

## Additional Resources

- [GitHub Actions Artifacts](https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
- [upload-artifact Action](https://github.com/actions/upload-artifact)
- [download-artifact Action](https://github.com/actions/download-artifact)
- [Sharing Data Between Jobs](https://docs.github.com/en/actions/using-jobs/passing-information-between-jobs)
