# GitHub Actions Basics

**Difficulty:** Beginner
**Estimated Time:** 30 minutes
**Prerequisites:** Basic YAML syntax, understanding of CI/CD concepts

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn the fundamentals of GitHub Actions workflow syntax by creating a basic workflow with build and test jobs. You'll understand how workflows are structured, how jobs run, and how to define steps that execute commands.

## Instructions

In this exercise, you'll create a GitHub Actions workflow file that builds and tests a simple application. The workflow should run when code is pushed to the main branch.

### Part 1: Create the Workflow Structure

1. Create a new file called `basic-workflow.yml` in the `exercises/cicd/pipelines/` directory
2. Define the workflow name as "Build and Test"
3. Configure the workflow to trigger on push events to the `main` branch
4. Add a `build` job that runs on `ubuntu-latest`

### Part 2: Add Build Steps

In the `build` job, add steps to:
1. Print "Starting build process..."
2. Create a file called `app.txt` with the content "Hello from CI/CD!"
3. Print "Build completed successfully"

### Part 3: Add Test Job

1. Add a `test` job that depends on the `build` job completing successfully
2. The test job should:
   - Print "Running tests..."
   - Echo "All tests passed!"

### Part 4: Validate and Run

1. Use the CI/CD simulator to validate your workflow
2. Execute the workflow and verify the output

## Expected Output

When you run the workflow with the simulator, you should see output similar to:

```
=== Running Job: build ===
Step: Checkout code
  ✓ Completed
Step: Build application
  Starting build process...
  ✓ Completed
Step: Create artifact
  ✓ Completed
Step: Verify build
  Build completed successfully
  ✓ Completed

=== Running Job: test ===
Step: Run tests
  Running tests...
  All tests passed!
  ✓ Completed

Pipeline completed successfully!
```

## Verification Steps

1. Validate your workflow YAML:
   ```bash
   docker exec devops-cicd cicd-sim validate /pipelines/basic-workflow.yml
   ```

2. Run the workflow:
   ```bash
   docker exec devops-cicd cicd-sim run --type github /pipelines/basic-workflow.yml
   ```

3. Verify both jobs complete successfully

## Hints

<details>
<summary>Hint 1: Workflow Structure</summary>

A GitHub Actions workflow file has this basic structure:

```yaml
name: Workflow Name
on: [trigger events]
jobs:
  job_name:
    runs-on: runner
    steps:
      - name: Step name
        run: command
```
</details>

<details>
<summary>Hint 2: Trigger Configuration</summary>

To trigger on push to main branch:

```yaml
on:
  push:
    branches:
      - main
```
</details>

<details>
<summary>Hint 3: Job Dependencies</summary>

To make a job depend on another job completing first, use the `needs` keyword:

```yaml
jobs:
  first_job:
    # ...
  second_job:
    needs: first_job
    # ...
```
</details>

<details>
<summary>Hint 4: Multi-line Commands</summary>

For multiple commands in a single step, use the pipe character:

```yaml
- name: Multiple commands
  run: |
    echo "First command"
    echo "Second command"
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

Create `exercises/cicd/pipelines/basic-workflow.yml`:

```yaml
name: Build and Test

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        run: echo "Checking out code..."

      - name: Build application
        run: echo "Starting build process..."

      - name: Create artifact
        run: echo "Hello from CI/CD!" > app.txt

      - name: Verify build
        run: |
          cat app.txt
          echo "Build completed successfully"

  test:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Run tests
        run: |
          echo "Running tests..."
          echo "All tests passed!"
```

### Explanation

**Workflow Structure:**
- `name`: Human-readable name for the workflow
- `on`: Defines when the workflow runs (triggers)
- `jobs`: Contains all the jobs in the workflow

**Job Configuration:**
- `runs-on`: Specifies the runner environment (ignored by local simulator)
- `steps`: List of steps to execute in order
- `needs`: Creates a dependency on another job

**Step Configuration:**
- `name`: Descriptive name for the step
- `run`: Shell command(s) to execute

**Key Concepts:**
1. Jobs run in parallel by default unless `needs` is specified
2. Steps within a job run sequentially
3. If any step fails, the job fails
4. The `needs` keyword ensures job ordering

</details>

## Additional Resources

- [GitHub Actions Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [GitHub Actions Quickstart](https://docs.github.com/en/actions/quickstart)
- [Understanding GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions)
