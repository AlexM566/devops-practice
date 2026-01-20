# Contributing to DevOps Interview Playground

Thank you for your interest in contributing to the DevOps Interview Playground! This document provides guidelines for adding new exercises, improving existing content, and extending the playground with new services.

## Table of Contents

- [How to Contribute](#how-to-contribute)
- [Adding New Exercises](#adding-new-exercises)
- [Exercise File Format](#exercise-file-format)
- [Adding New Services](#adding-new-services)
- [Improving Documentation](#improving-documentation)
- [Testing Your Contributions](#testing-your-contributions)
- [Submission Guidelines](#submission-guidelines)

## How to Contribute

Contributions are welcome in the following areas:

1. **New Exercises**: Add exercises for existing or new technology domains
2. **Exercise Improvements**: Fix errors, clarify instructions, or improve existing exercises
3. **New Services**: Add new containerized services to the environment
4. **Documentation**: Improve README, troubleshooting guides, or exercise descriptions
5. **Bug Fixes**: Fix issues with configurations or scripts
6. **Examples**: Add more Kubernetes manifests or Terraform examples

## Adding New Exercises

### Before You Start

1. Check if a similar exercise already exists
2. Ensure the required services/tools are available in the environment
3. Test your exercise thoroughly before submitting
4. Follow the exercise file format (see below)

### Exercise Guidelines

**Good exercises should:**
- Have a clear, specific learning objective
- Be completable in 15-45 minutes
- Include step-by-step instructions
- Provide expected output for verification
- Include progressive hints (don't give away the solution immediately)
- Include a complete solution in a collapsible section
- Be appropriate for the stated difficulty level

**Avoid:**
- Exercises that require external services or accounts
- Overly complex multi-step exercises (break them into smaller exercises)
- Exercises that depend on specific timing or race conditions
- Exercises that require downloading large files

### Difficulty Levels

- **Beginner**: Basic commands and concepts, minimal prerequisites
- **Intermediate**: Combines multiple concepts, requires understanding of fundamentals
- **Advanced**: Complex scenarios, troubleshooting, optimization, or architecture

## Exercise File Format

All exercise files MUST follow this standardized format with Quick Navigation links:

```markdown
# Exercise Title

**Difficulty:** Beginner | Intermediate | Advanced
**Estimated Time:** X minutes
**Prerequisites:** List any required knowledge or previous exercises

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

A clear, concise statement of what the learner will accomplish and learn.
Should be 1-3 sentences explaining the goal and why it's important.

## Instructions

Step-by-step instructions for completing the exercise:

1. First step with specific command or action
   ```bash
   command-to-run
   ```

2. Second step explaining what to do
   - Sub-point if needed
   - Another sub-point

3. Continue with clear, numbered steps

## Expected Output

Provide example output that learners should see when successful:

```
Example output here
Showing what success looks like
```

Or describe what they should observe:
- Service should respond with status 200
- Pod should be in Running state
- File should contain specific content

## Verification Steps

How to verify the solution is correct:

1. Check X with command Y
   ```bash
   verification-command
   ```

2. Verify Z is present or working
   ```bash
   another-verification-command
   ```

## Hints

<details>
<summary>Hint 1: Getting Started</summary>

First level hint that points in the right direction without giving away the solution.
</details>

<details>
<summary>Hint 2: Common Issues</summary>

More specific guidance about common mistakes or issues.
</details>

<details>
<summary>Hint 3: Solution Approach</summary>

Detailed approach explaining the strategy without complete commands.
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

Complete solution with all commands and explanations:

```bash
# Step 1: Do this
command-one

# Step 2: Do that
command-two

# Step 3: Verify
command-three
```

**Explanation:**
- Why this approach works
- Key concepts demonstrated
- What each command does

</details>

## Additional Resources

- [Link to official documentation](https://example.com)
- [Related concept or tutorial](https://example.com)
- [Advanced reading](https://example.com)

## Clean Up (if applicable)

If the exercise creates resources that should be cleaned up:

```bash
# Remove created resources
cleanup-command
```
```

### Required Sections

Every exercise MUST include:

1. **Title** (H1 heading)
2. **Metadata** (Difficulty, Estimated Time, Prerequisites)
3. **Quick Navigation** - Blockquote with links to Instructions, Hints, and Solution sections
4. **Objective** - What will be learned
5. **Instructions** - Step-by-step guide
6. **Expected Output** - What success looks like
7. **Verification Steps** - How to confirm correctness
8. **Hints** - At least 2-3 progressive hints in collapsible sections
9. **Horizontal Rule** - A `---` separator before the Solution section
10. **Solution** - Complete solution in a collapsible section at the end of the file

### Optional Sections

- **Additional Resources** - Links to documentation or related content
- **Clean Up** - Commands to remove created resources
- **Troubleshooting** - Common issues specific to this exercise
- **Challenge** - Optional advanced variation of the exercise

### File Naming Convention

- Use lowercase with hyphens: `exercise-name.md`
- Prefix with domain: `docker-basics.md`, `k8s-pods.md`, `linux-files.md`
- Be descriptive but concise

### File Location

Place exercises in the appropriate domain directory:

```
exercises/
├── docker/          # Docker-related exercises
├── kubernetes/      # Kubernetes exercises
├── linux/           # Linux administration exercises
├── networking/      # Networking exercises
├── terraform/       # Terraform exercises
├── python/          # Python DevOps exercises
│   └── workspace/   # User workspace for Python code
└── cicd/            # CI/CD pipeline exercises
    └── pipelines/   # User workspace for pipeline files
```

## Python Exercise Guidelines

Python exercises use the dedicated `devops-python` container with pre-installed DevOps libraries.

### Python Exercise Structure

Python exercises should follow the standard exercise format with these additions:

1. **Challenge Section**: Include a coding challenge with clear requirements
2. **Test Cases**: Provide test cases or verification commands
3. **Starter Code**: Include starter code template when appropriate
4. **Solution Code**: Complete working solution in the Solution section

### Python Exercise Template

```markdown
# Python Exercise Title

**Difficulty:** Beginner | Intermediate
**Estimated Time:** X minutes
**Prerequisites:** Python basics (for intermediate exercises)

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

What the learner will accomplish.

## Instructions

### Setup

1. Access the Python container:
   ```bash
   docker exec -it devops-python bash
   ```

2. Create your solution file:
   ```bash
   cd /workspace
   touch solution.py
   ```

### Challenge

Describe the coding challenge with:
- Clear requirements
- Input/output format
- Constraints

### Test Cases

```python
# Test case 1
Input: ...
Expected Output: ...

# Test case 2
Input: ...
Expected Output: ...
```

## Verification

How to verify the solution:

```bash
python solution.py
# or
pytest test_solution.py
```

## Hints

<details>
<summary>Hint 1: Getting Started</summary>
Guidance without full solution
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

```python
# Complete solution code
```

**Explanation:**
Why this solution works...

</details>
```

### Available Python Libraries

The `devops-python` container includes:
- `requests` - HTTP requests
- `boto3` - AWS SDK
- `pyyaml` - YAML parsing
- `jinja2` - Template engine
- `paramiko` - SSH client
- `python-dotenv` - Environment variables
- `click` - CLI framework
- `rich` - Terminal formatting
- `pytest` - Testing framework

## CI/CD Exercise Guidelines

CI/CD exercises use the `devops-cicd` simulator to validate and run pipelines locally.

### CI/CD Exercise Structure

CI/CD exercises should include:

1. **Pipeline Template**: YAML template for users to complete
2. **Syntax Explanation**: Explain the pipeline syntax and structure
3. **Validation Steps**: How to validate the pipeline YAML
4. **Execution Steps**: How to run the pipeline locally

### CI/CD Exercise Template

```markdown
# CI/CD Exercise Title

**Difficulty:** Beginner | Intermediate
**Estimated Time:** X minutes
**Pipeline Type:** GitHub Actions | Azure Pipelines

> **Quick Navigation:** [Instructions](#instructions) | [Hints](#hints) | [Solution](#solution)

## Objective

What the learner will accomplish.

## Background

Explain the CI/CD concepts covered.

## Instructions

### Setup

1. Access the CI/CD simulator:
   ```bash
   docker exec -it devops-cicd bash
   ```

2. Create your pipeline file:
   ```bash
   cd /pipelines
   touch my-workflow.yml
   ```

### Pipeline Template

Complete this template:

```yaml
# Pipeline template with TODOs
name: My Workflow
on: push

jobs:
  build:
    # TODO: Add steps
```

### Requirements

- Requirement 1
- Requirement 2

## Validation

Validate your pipeline:

```bash
python -m simulator.cli validate my-workflow.yml --type github
```

## Execution

Run your pipeline:

```bash
python -m simulator.cli run my-workflow.yml --type github
```

## Expected Output

What success looks like.

## Hints

<details>
<summary>Hint 1: Getting Started</summary>
Guidance without full solution
</details>

---

## Solution

<details>
<summary>Click to reveal solution</summary>

```yaml
# Complete pipeline YAML
```

**Explanation:**
Why this solution works...

</details>
```

### Supported Pipeline Features

The CI/CD simulator supports:

**GitHub Actions:**
- Jobs and steps
- `run` commands
- Environment variables (`env`)
- Conditionals (`if`)
- Basic matrix strategy

**Azure Pipelines:**
- Stages and jobs
- `script` steps
- Environment variables
- Conditions

## Adding New Services

### Before Adding a Service

Consider:
- Is this service commonly used in DevOps workflows?
- Does it add educational value?
- Will it significantly increase resource requirements?
- Is there a lightweight alternative?

### Service Requirements

New services should:
- Use official or well-maintained Docker images
- Include health checks
- Have resource limits defined
- Be properly networked with other services
- Include configuration files in `services/SERVICE_NAME/`
- Be documented in README.md

### Adding a Service to docker-compose.yml

Follow this template:

```yaml
service-name:
  image: official/image:tag
  container_name: service-name
  ports:
    - "HOST_PORT:CONTAINER_PORT"
  networks:
    - appropriate-network
  volumes:
    - service-data:/data
    - ./services/service-name/config.yml:/etc/service/config.yml:ro
  environment:
    - ENV_VAR=value
  healthcheck:
    test: ["CMD", "health-check-command"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 40s
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 512M
  restart: unless-stopped
```

### Service Configuration Files

- Place configuration files in `services/SERVICE_NAME/`
- Document all configuration options
- Use sensible defaults
- Include comments explaining key settings

### Updating Documentation

When adding a service, update:

1. **README.md**:
   - Add to "Available Services" table
   - Include access URL and credentials
   - Add to troubleshooting if needed

2. **EXERCISES.md**:
   - Add exercises that use the new service
   - Update statistics and learning paths

3. **docker-compose.yml**:
   - Add comments explaining the service purpose
   - Document any special configuration

## Improving Documentation

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Test all commands and URLs
- Keep formatting consistent
- Use proper markdown syntax

### Areas for Documentation Improvement

- Troubleshooting guides for common issues
- More detailed service descriptions
- Architecture diagrams
- Video tutorials or screencasts
- Translations to other languages

## Testing Your Contributions

### Before Submitting

1. **Test the Environment**:
   ```bash
   docker-compose down -v
   docker-compose up -d
   docker-compose ps  # All services should be healthy
   ```

2. **Test New Exercises**:
   - Complete the exercise from scratch
   - Verify instructions are clear and accurate
   - Confirm expected output matches actual output
   - Test all hints are helpful
   - Verify solution works correctly
   - Test on a fresh environment

3. **Test Python Exercises**:
   - Verify the Python container starts: `docker exec -it devops-python python --version`
   - Test all required libraries are available
   - Run the solution code and verify it works
   - Run any test cases provided

4. **Test CI/CD Exercises**:
   - Verify the CI/CD simulator starts: `docker exec -it devops-cicd python -m simulator.cli --help`
   - Validate the pipeline YAML
   - Execute the pipeline and verify output
   - Test both GitHub Actions and Azure Pipelines syntax as appropriate

5. **Test New Services**:
   - Verify service starts successfully
   - Check health status
   - Test connectivity from other services
   - Verify resource usage is reasonable
   - Test service functionality

6. **Check Documentation**:
   - Verify all links work
   - Check for typos and formatting issues
   - Ensure code blocks render correctly
   - Test all commands in documentation

### Testing Checklist

- [ ] Environment starts successfully with `docker-compose up`
- [ ] All services reach healthy state
- [ ] New exercises can be completed as written
- [ ] Expected outputs match actual outputs
- [ ] Solutions work correctly
- [ ] Documentation is accurate and complete
- [ ] No broken links
- [ ] Resource usage is acceptable
- [ ] Changes work on Windows (WSL), macOS, and Linux
- [ ] Python exercises: code runs in devops-python container
- [ ] CI/CD exercises: pipelines validate and execute in devops-cicd container

## Submission Guidelines

### Pull Request Process

1. **Fork the repository**

2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**:
   - Follow the guidelines in this document
   - Test thoroughly
   - Update documentation

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Add: Brief description of changes"
   ```
   
   Use conventional commit messages:
   - `Add:` for new features or exercises
   - `Fix:` for bug fixes
   - `Update:` for improvements to existing content
   - `Docs:` for documentation changes

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Provide a clear description of changes
   - Reference any related issues
   - Include testing notes
   - Add screenshots if relevant

### Pull Request Description Template

```markdown
## Description
Brief description of what this PR does

## Type of Change
- [ ] New exercise
- [ ] Exercise improvement
- [ ] New service
- [ ] Bug fix
- [ ] Documentation update

## Exercise Type (if applicable)
- [ ] Docker
- [ ] Kubernetes
- [ ] Linux
- [ ] Networking
- [ ] Terraform
- [ ] Python
- [ ] CI/CD

## Testing
- [ ] Tested on Windows/WSL
- [ ] Tested on macOS
- [ ] Tested on Linux
- [ ] All services start successfully
- [ ] Exercise can be completed as written
- [ ] Documentation is accurate
- [ ] Python code runs in devops-python container (if applicable)
- [ ] CI/CD pipelines validate and execute (if applicable)

## Checklist
- [ ] Follows exercise file format
- [ ] Includes all required sections
- [ ] Updated 02-exercises.md (if adding exercise)
- [ ] Updated README.md (if adding service)
- [ ] Tested thoroughly
- [ ] No broken links
- [ ] Proper markdown formatting

## Additional Notes
Any additional context or notes for reviewers
```

## Code of Conduct

### Be Respectful

- Be welcoming to newcomers
- Be patient with questions
- Provide constructive feedback
- Respect different skill levels and backgrounds

### Quality Standards

- Test your contributions thoroughly
- Follow established formats and conventions
- Write clear, understandable documentation
- Keep exercises focused and achievable

## Questions or Need Help?

If you have questions about contributing:

1. Check existing exercises for examples
2. Review this contributing guide
3. Open an issue for discussion
4. Ask for clarification before starting large changes

## Recognition

Contributors will be recognized in:
- Pull request acknowledgments
- Release notes
- Project documentation

Thank you for helping make the DevOps Interview Playground better for everyone! 🎉
