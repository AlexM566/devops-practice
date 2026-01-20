# GitHub Actions Matrix Strategy

**Difficulty:** Intermediate
**Estimated Time:** 35 minutes
**Prerequisites:** GitHub Actions basics, YAML syntax

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

Learn how to use matrix strategies in GitHub Actions to run the same job with different configurations. Matrix builds are essential for testing across multiple versions, operating systems, or configurations without duplicating workflow code.

## Instructions

In this exercise, you'll create a workflow that tests an application across multiple Python versions and operating systems using a matrix strategy.

### Part 1: Create the Matrix Workflow

1. Create a new file called `matrix-workflow.yml` in the `exercises/cicd/pipelines/` directory
2. Define the workflow name as "Matrix Build"
3. Configure the workflow to trigger on push to any branch

### Part 2: Define the Matrix Strategy

1. Create a `test` job with a matrix strategy
2. The matrix should include:
   - Python versions: 3.9, 3.10, 3.11
   - Operating systems: ubuntu, debian
3. This should result in 6 job combinations (3 versions × 2 OS)

### Part 3: Use Matrix Variables

1. Add steps that use the matrix variables
2. Print which Python version and OS combination is being tested
3. Simulate running tests for that configuration

### Part 4: Add a Failing Combination (Optional)

1. Use the `exclude` feature to skip Python 3.9 on debian
2. Or use `include` to add an extra configuration

## Expected Output

When you run the workflow, you should see multiple job runs:

```
=== Running Job: test (python: 3.9, os: ubuntu) ===
Step: Setup environment
  Setting up Python 3.9 on ubuntu
  ✓ Completed
Step: Run tests
  Running tests for Python 3.9 on ubuntu
  Tests passed!
  ✓ Completed

=== Running Job: test (python: 3.10, os: ubuntu) ===
...

=== Running Job: test (python: 3.11, os: debian) ===
...

Matrix build completed: 6 configurations tested
```

## Verification Steps

1. Validate your workflow:
   ```bash
   docker exec devops-cicd cicd-sim validate /pipelines/matrix-workflow.yml
   ```

2. Run the workflow:
   ```bash
   docker exec devops-cicd cicd-sim run --type github /pipelines/matrix-workflow.yml
   ```

3. Verify all matrix combinations are executed

## Hints

<details>
<summary>Hint 1: Basic Matrix Syntax</summary>

Matrix strategy is defined under the job:

```yaml
jobs:
  test:
    strategy:
      matrix:
        key: [value1, value2, value3]
```
</details>

<details>
<summary>Hint 2: Multiple Matrix Dimensions</summary>

You can have multiple dimensions in a matrix:

```yaml
strategy:
  matrix:
    os: [ubuntu, debian]
    version: [1.0, 2.0]
```

This creates 4 combinations (2 × 2).
</details>

<details>
<summary>Hint 3: Accessing Matrix Values</summary>

Access matrix values in steps using the matrix context:

```yaml
steps:
  - run: echo "OS is ${{ matrix.os }}"
  - run: echo "Version is ${{ matrix.version }}"
```
</details>

<details>
<summary>Hint 4: Excluding Combinations</summary>

To skip specific combinations:

```yaml
strategy:
  matrix:
    os: [ubuntu, debian]
    version: [1.0, 2.0]
    exclude:
      - os: debian
        version: 1.0
```
</details>

---

## Solution

<details>
<summary>Click to reveal complete solution</summary>

### Complete Solution

Create `exercises/cicd/pipelines/matrix-workflow.yml`:

```yaml
name: Matrix Build

on:
  push:
    branches:
      - '*'

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python: ['3.9', '3.10', '3.11']
        os: [ubuntu, debian]
        exclude:
          - python: '3.9'
            os: debian
      fail-fast: false

    steps:
      - name: Setup environment
        run: |
          echo "Setting up Python ${{ matrix.python }} on ${{ matrix.os }}"

      - name: Display configuration
        run: |
          echo "==================================="
          echo "Python Version: ${{ matrix.python }}"
          echo "Operating System: ${{ matrix.os }}"
          echo "==================================="

      - name: Install dependencies
        run: |
          echo "Installing dependencies for Python ${{ matrix.python }}..."
          echo "pip install -r requirements.txt"

      - name: Run tests
        run: |
          echo "Running tests for Python ${{ matrix.python }} on ${{ matrix.os }}"
          echo "pytest --version ${{ matrix.python }}"
          echo "Tests passed!"

      - name: Report results
        run: |
          echo "Test results for ${{ matrix.os }}-py${{ matrix.python }}: SUCCESS"
```

### Explanation

**Matrix Strategy:**
- `matrix`: Defines the variables and their possible values
- Each combination of values creates a separate job run
- With 3 Python versions × 2 OS = 6 combinations (minus 1 excluded = 5)

**Matrix Options:**
- `fail-fast: false`: Continue running other matrix jobs even if one fails
- `exclude`: Skip specific combinations
- `include`: Add extra combinations with additional variables

**Accessing Matrix Values:**
- Use `${{ matrix.variable_name }}` syntax
- Available in any step within the job
- Can be used in `run` commands, `env` variables, or `with` parameters

**Key Concepts:**
1. Matrix builds run in parallel (when resources allow)
2. Each matrix combination is a separate job instance
3. Matrix values can be strings, numbers, or booleans
4. The `exclude` and `include` keywords modify the matrix

**Common Use Cases:**
- Testing across multiple language versions
- Testing on different operating systems
- Testing with different dependency versions
- Testing different feature flag combinations

</details>

## Additional Resources

- [GitHub Actions Matrix Strategy](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)
- [Matrix Strategy Examples](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstrategymatrix)
- [Fail-fast and Max-parallel](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs#handling-failures)
