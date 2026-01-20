# Azure Pipelines Multi-Stage with Conditions

**Difficulty:** Intermediate
**Estimated Time:** 45 minutes
**Prerequisites:** Azure Pipelines basics, YAML syntax

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to create complex multi-stage pipelines in Azure DevOps with stage dependencies, conditions, and environment-specific deployments. You'll understand how to control pipeline flow based on conditions and create deployment pipelines for multiple environments.

## Instructions

In this exercise, you'll create a multi-stage pipeline that deploys to development, staging, and production environments with appropriate conditions and approvals.

### Part 1: Create the Pipeline Structure

1. Create a new file called `multi-stage-pipeline.yml` in the `exercises/cicd/pipelines/` directory
2. Configure the pipeline to trigger on `main` and `develop` branches
3. Define variables for different environments

### Part 2: Create Build and Test Stages

1. Add a `Build` stage that compiles the application
2. Add a `Test` stage that runs after Build
3. Both stages should run for all branches

### Part 3: Create Environment Deployment Stages

1. Add a `DeployDev` stage that:
   - Runs after Test
   - Always deploys for the `develop` branch
   - Deploys to the development environment

2. Add a `DeployStaging` stage that:
   - Runs after DeployDev (or Test if DeployDev is skipped)
   - Only runs for the `main` branch
   - Deploys to the staging environment

3. Add a `DeployProd` stage that:
   - Runs after DeployStaging
   - Only runs for the `main` branch
   - Includes a condition to check if previous stages succeeded

### Part 4: Add Conditions

1. Use conditions to control which stages run based on:
   - Branch name
   - Previous stage success
   - Variable values

## Expected Output

For a push to `main` branch:
```
=== Running Stage: Build ===
  Building application...
  ✓ Build completed

=== Running Stage: Test ===
  Running tests...
  ✓ Tests passed

=== Skipping Stage: DeployDev ===
  Condition not met: branch is not develop

=== Running Stage: DeployStaging ===
  Deploying to staging...
  ✓ Staging deployment completed

=== Running Stage: DeployProd ===
  Deploying to production...
  ✓ Production deployment completed

Pipeline completed successfully!
```

For a push to `develop` branch:
```
=== Running Stage: Build ===
  ✓ Build completed

=== Running Stage: Test ===
  ✓ Tests passed

=== Running Stage: DeployDev ===
  Deploying to development...
  ✓ Development deployment completed

=== Skipping Stage: DeployStaging ===
  Condition not met: branch is not main

=== Skipping Stage: DeployProd ===
  Condition not met: branch is not main

Pipeline completed!
```

## Verification Steps

1. Validate your pipeline:
   ```bash
   docker exec devops-cicd cicd-sim validate /pipelines/multi-stage-pipeline.yml
   ```

2. Run the pipeline (simulating main branch):
   ```bash
   docker exec devops-cicd cicd-sim run --type azure /pipelines/multi-stage-pipeline.yml
   ```

3. Verify correct stages run based on conditions

## Hints

<details>
<summary>Hint 1: Stage Conditions</summary>

Use the `condition` keyword to control stage execution:

```yaml
stages:
  - stage: Deploy
    condition: eq(variables['Build.SourceBranch'], 'refs/heads/main')
```
</details>

<details>
<summary>Hint 2: Multiple Dependencies</summary>

A stage can depend on multiple stages:

```yaml
- stage: DeployProd
  dependsOn:
    - DeployStaging
    - Test
```
</details>

<details>
<summary>Hint 3: Condition Functions</summary>

Common condition functions:
- `eq(a, b)` - equals
- `ne(a, b)` - not equals
- `and(a, b)` - both true
- `or(a, b)` - either true
- `succeeded()` - previous stage succeeded
- `failed()` - previous stage failed
</details>

<details>
<summary>Hint 4: Branch Conditions</summary>

Check branch name in conditions:

```yaml
condition: |
  and(
    succeeded(),
    eq(variables['Build.SourceBranch'], 'refs/heads/main')
  )
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

Create `exercises/cicd/pipelines/multi-stage-pipeline.yml`:

```yaml
trigger:
  branches:
    include:
      - main
      - develop

pool:
  vmImage: 'ubuntu-latest'

variables:
  buildConfiguration: 'Release'
  devEnvironment: 'development'
  stagingEnvironment: 'staging'
  prodEnvironment: 'production'

stages:
  # Build Stage - runs for all branches
  - stage: Build
    displayName: 'Build Application'
    jobs:
      - job: BuildJob
        steps:
          - script: |
              echo "================================"
              echo "BUILDING APPLICATION"
              echo "================================"
              echo "Branch: $(Build.SourceBranch)"
              echo "Configuration: $(buildConfiguration)"
              echo "Building..."
              mkdir -p artifacts
              echo "app-v1.0.0" > artifacts/app.txt
              echo "Build completed successfully!"
            displayName: 'Build'

  # Test Stage - runs for all branches after Build
  - stage: Test
    displayName: 'Run Tests'
    dependsOn: Build
    jobs:
      - job: TestJob
        steps:
          - script: |
              echo "================================"
              echo "RUNNING TESTS"
              echo "================================"
              echo "Running unit tests..."
              echo "Running integration tests..."
              echo "All tests passed!"
            displayName: 'Run tests'

  # Deploy to Development - only for develop branch
  - stage: DeployDev
    displayName: 'Deploy to Development'
    dependsOn: Test
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/develop')
      )
    variables:
      environment: $(devEnvironment)
    jobs:
      - job: DeployDevJob
        steps:
          - script: |
              echo "================================"
              echo "DEPLOYING TO DEVELOPMENT"
              echo "================================"
              echo "Environment: $(environment)"
              echo "Deploying application..."
              echo "Configuring development settings..."
              echo "Development deployment completed!"
            displayName: 'Deploy to Dev'

  # Deploy to Staging - only for main branch
  - stage: DeployStaging
    displayName: 'Deploy to Staging'
    dependsOn: Test
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
    variables:
      environment: $(stagingEnvironment)
    jobs:
      - job: DeployStagingJob
        steps:
          - script: |
              echo "================================"
              echo "DEPLOYING TO STAGING"
              echo "================================"
              echo "Environment: $(environment)"
              echo "Deploying application..."
              echo "Running smoke tests..."
              echo "Staging deployment completed!"
            displayName: 'Deploy to Staging'

          - script: |
              echo "Running post-deployment verification..."
              echo "Health check: OK"
              echo "API check: OK"
              echo "Staging verification passed!"
            displayName: 'Verify Staging'

  # Deploy to Production - only for main branch, after staging
  - stage: DeployProd
    displayName: 'Deploy to Production'
    dependsOn: DeployStaging
    condition: |
      and(
        succeeded(),
        eq(variables['Build.SourceBranch'], 'refs/heads/main')
      )
    variables:
      environment: $(prodEnvironment)
    jobs:
      - job: DeployProdJob
        steps:
          - script: |
              echo "================================"
              echo "DEPLOYING TO PRODUCTION"
              echo "================================"
              echo "Environment: $(environment)"
              echo "⚠️  Production deployment starting..."
            displayName: 'Pre-deployment notice'

          - script: |
              echo "Creating backup..."
              echo "Backup completed: backup-$(date +%Y%m%d-%H%M%S)"
            displayName: 'Create backup'

          - script: |
              echo "Deploying application to production..."
              echo "Updating load balancer..."
              echo "Rolling out to servers..."
              echo "Production deployment completed!"
            displayName: 'Deploy to Production'

          - script: |
              echo "================================"
              echo "POST-DEPLOYMENT VERIFICATION"
              echo "================================"
              echo "Health check: OK"
              echo "Performance check: OK"
              echo "Security scan: OK"
              echo "================================"
              echo "✓ Production deployment verified!"
            displayName: 'Verify Production'

  # Notification Stage - always runs
  - stage: Notify
    displayName: 'Send Notifications'
    dependsOn:
      - Build
      - Test
      - DeployDev
      - DeployStaging
      - DeployProd
    condition: always()
    jobs:
      - job: NotifyJob
        steps:
          - script: |
              echo "================================"
              echo "PIPELINE SUMMARY"
              echo "================================"
              echo "Branch: $(Build.SourceBranch)"
              echo "Build: completed"
              echo "Tests: completed"
              echo "Sending notification..."
              echo "Pipeline execution complete!"
            displayName: 'Send notification'
```

### Explanation

**Multi-Stage Pipeline Flow:**
```
Build → Test → DeployDev (develop only)
            → DeployStaging (main only) → DeployProd (main only)
            → Notify (always)
```

**Condition Syntax:**
- `succeeded()`: Previous dependencies succeeded
- `failed()`: Previous dependencies failed
- `always()`: Run regardless of previous status
- `eq(a, b)`: Equality comparison
- `and(a, b)`: Both conditions must be true

**Branch-Based Conditions:**
- `variables['Build.SourceBranch']` contains the full ref path
- For `main` branch: `refs/heads/main`
- For `develop` branch: `refs/heads/develop`

**Stage Dependencies:**
- `dependsOn: StageName` - single dependency
- `dependsOn: [Stage1, Stage2]` - multiple dependencies
- Stages without `dependsOn` run after all previous stages

**Stage-Level Variables:**
- Variables can be defined at stage level
- Override pipeline-level variables
- Useful for environment-specific configuration

**Best Practices:**
1. Use meaningful stage and job names
2. Add conditions to prevent unnecessary deployments
3. Include verification steps after deployments
4. Use the `always()` condition for notifications
5. Create backups before production deployments

**Real-World Additions:**
In production pipelines, you would also add:
- Approval gates before production
- Environment resources with checks
- Deployment strategies (rolling, blue-green)
- Rollback mechanisms

</details>

## Additional Resources

- [Azure Pipelines Stages](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/stages)
- [Conditions in Azure Pipelines](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/conditions)
- [Deployment Jobs](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/deployment-jobs)
- [Environments](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/environments)
