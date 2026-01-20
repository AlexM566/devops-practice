# Azure Pipelines Basics

**Difficulty:** Beginner
**Estimated Time:** 35 minutes
**Prerequisites:** Basic YAML syntax, understanding of CI/CD concepts

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn the fundamentals of Azure Pipelines YAML syntax by creating a basic pipeline with stages and jobs. You'll understand how Azure Pipelines structures workflows differently from GitHub Actions and how to define stages, jobs, and steps.

## Instructions

In this exercise, you'll create an Azure Pipeline that builds, tests, and deploys an application using the stage-job-step hierarchy.

### Part 1: Create the Pipeline Structure

1. Create a new file called `basic-pipeline.yml` in the `exercises/cicd/pipelines/` directory
2. Configure the pipeline to trigger on the `main` branch
3. Define a variable for the build configuration

### Part 2: Create the Build Stage

1. Add a stage called `Build` with display name "Build Stage"
2. Add a job called `BuildJob` within the stage
3. Add steps to:
   - Display the build configuration
   - Create a build artifact
   - Show build completion message

### Part 3: Create the Test Stage

1. Add a stage called `Test` that depends on the Build stage
2. Add a job with steps to:
   - Display "Running tests..."
   - Simulate test execution
   - Report test results

### Part 4: Validate and Run

1. Use the CI/CD simulator to validate your pipeline
2. Execute the pipeline and verify the output

## Expected Output

```
=== Running Stage: Build ===

--- Running Job: BuildJob ---
Step: Display configuration
  Build Configuration: Release
  ✓ Completed
Step: Build application
  Building application...
  ✓ Completed
Step: Create artifact
  Creating build artifact...
  ✓ Completed

=== Running Stage: Test ===

--- Running Job: TestJob ---
Step: Run unit tests
  Running tests...
  ✓ Completed
Step: Report results
  All tests passed!
  ✓ Completed

Pipeline completed successfully!
```

## Verification Steps

1. Validate your pipeline YAML:
   ```bash
   docker exec devops-cicd cicd-sim validate /pipelines/basic-pipeline.yml
   ```

2. Run the pipeline:
   ```bash
   docker exec devops-cicd cicd-sim run --type azure /pipelines/basic-pipeline.yml
   ```

3. Verify both stages complete successfully

## Hints

<details>
<summary>Hint 1: Azure Pipeline Structure</summary>

Azure Pipelines has a hierarchical structure:

```yaml
trigger:
  - main

stages:
  - stage: StageName
    jobs:
      - job: JobName
        steps:
          - script: echo "Hello"
```
</details>

<details>
<summary>Hint 2: Variables</summary>

Define variables at the pipeline level:

```yaml
variables:
  buildConfiguration: 'Release'

# Use in steps:
steps:
  - script: echo $(buildConfiguration)
```
</details>

<details>
<summary>Hint 3: Stage Dependencies</summary>

Stages run sequentially by default, but you can be explicit:

```yaml
stages:
  - stage: Build
    # ...
  - stage: Test
    dependsOn: Build
    # ...
```
</details>

<details>
<summary>Hint 4: Script vs Task</summary>

Azure Pipelines uses `script` for shell commands:

```yaml
steps:
  - script: |
      echo "Line 1"
      echo "Line 2"
    displayName: 'Run script'
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

Create `exercises/cicd/pipelines/basic-pipeline.yml`:

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  artifactName: 'drop'

stages:
  - stage: Build
    displayName: 'Build Stage'
    jobs:
      - job: BuildJob
        displayName: 'Build Application'
        steps:
          - script: |
              echo "Build Configuration: $(buildConfiguration)"
              echo "Artifact Name: $(artifactName)"
            displayName: 'Display configuration'

          - script: |
              echo "Building application..."
              mkdir -p $(Build.ArtifactStagingDirectory)
              echo "console.log('Hello from Azure Pipelines!');" > $(Build.ArtifactStagingDirectory)/app.js
              echo "Build completed successfully"
            displayName: 'Build application'

          - script: |
              echo "Creating build artifact..."
              echo '{"version": "1.0.0", "config": "$(buildConfiguration)"}' > $(Build.ArtifactStagingDirectory)/build-info.json
              ls -la $(Build.ArtifactStagingDirectory)
            displayName: 'Create artifact'

          - script: echo "Build stage completed!"
            displayName: 'Build completion'

  - stage: Test
    displayName: 'Test Stage'
    dependsOn: Build
    jobs:
      - job: TestJob
        displayName: 'Run Tests'
        steps:
          - script: |
              echo "Running tests..."
              echo "Executing unit tests..."
              echo "Executing integration tests..."
            displayName: 'Run unit tests'

          - script: |
              echo "================================"
              echo "TEST RESULTS"
              echo "================================"
              echo "Unit Tests: 10 passed, 0 failed"
              echo "Integration Tests: 5 passed, 0 failed"
              echo "================================"
              echo "All tests passed!"
            displayName: 'Report results'

  - stage: Deploy
    displayName: 'Deploy Stage'
    dependsOn: Test
    jobs:
      - job: DeployJob
        displayName: 'Deploy Application'
        steps:
          - script: |
              echo "Deploying application..."
              echo "Environment: Production"
              echo "Configuration: $(buildConfiguration)"
            displayName: 'Deploy to production'

          - script: |
              echo "Deployment completed successfully!"
              echo "Application is now live."
            displayName: 'Deployment confirmation'
```

### Explanation

**Azure Pipelines Structure:**
- `trigger`: Defines which branches trigger the pipeline
- `pool`: Specifies the agent pool (ignored by local simulator)
- `variables`: Pipeline-level variables
- `stages`: Top-level grouping of jobs

**Stage Configuration:**
- `stage`: Unique identifier for the stage
- `displayName`: Human-readable name
- `dependsOn`: Explicit dependency on other stages
- `jobs`: List of jobs within the stage

**Job Configuration:**
- `job`: Unique identifier for the job
- `displayName`: Human-readable name
- `steps`: List of steps to execute

**Step Configuration:**
- `script`: Shell command(s) to execute
- `displayName`: Name shown in logs

**Key Differences from GitHub Actions:**
1. Azure uses stages → jobs → steps (3 levels)
2. GitHub uses jobs → steps (2 levels)
3. Azure uses `script` instead of `run`
4. Azure uses `$(variable)` syntax instead of `${{ variable }}`
5. Azure has built-in variables like `$(Build.ArtifactStagingDirectory)`

**Built-in Variables:**
- `$(Build.ArtifactStagingDirectory)`: Directory for artifacts
- `$(Build.BuildId)`: Unique build identifier
- `$(Build.SourceBranch)`: Branch that triggered the build

</details>

## Additional Resources

- [Azure Pipelines YAML Schema](https://docs.microsoft.com/en-us/azure/devops/pipelines/yaml-schema)
- [Azure Pipelines Key Concepts](https://docs.microsoft.com/en-us/azure/devops/pipelines/get-started/key-pipelines-concepts)
- [Predefined Variables](https://docs.microsoft.com/en-us/azure/devops/pipelines/build/variables)
