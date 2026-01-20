"""Step executor for CI/CD pipeline simulation."""

import subprocess
import os
import re
from dataclasses import dataclass, field
from typing import Optional
from .parser import Pipeline, Job, Step


@dataclass
class StepResult:
    """Result of executing a single step."""
    step_name: str
    success: bool
    exit_code: int
    output: str
    error: str = ""
    skipped: bool = False
    skip_reason: str = ""


@dataclass
class JobResult:
    """Result of executing a job."""
    job_name: str
    success: bool
    step_results: list[StepResult] = field(default_factory=list)


@dataclass
class PipelineResult:
    """Result of executing a pipeline."""
    pipeline_name: str
    success: bool
    job_results: list[JobResult] = field(default_factory=list)


class StepExecutor:
    """Executes pipeline steps as shell commands."""

    def __init__(self, working_dir: str = None):
        self.working_dir = working_dir or os.getcwd()
        self.global_env: dict = {}

    def execute_pipeline(self, pipeline: Pipeline, job_filter: str = None) -> PipelineResult:
        """Execute all jobs in a pipeline."""
        self.global_env = dict(os.environ)
        self.global_env.update(pipeline.env)

        result = PipelineResult(
            pipeline_name=pipeline.name,
            success=True,
            job_results=[]
        )

        # Handle Azure Pipelines with stages
        if pipeline.stages:
            for stage in pipeline.stages:
                for job in stage.jobs:
                    if job_filter and job.name != job_filter:
                        continue
                    job_result = self.execute_job(job)
                    result.job_results.append(job_result)
                    if not job_result.success:
                        result.success = False
        else:
            # GitHub Actions or simple Azure Pipelines
            for job in pipeline.jobs:
                if job_filter and job.name != job_filter:
                    continue
                job_result = self.execute_job(job)
                result.job_results.append(job_result)
                if not job_result.success:
                    result.success = False

        return result


    def execute_job(self, job: Job) -> JobResult:
        """Execute all steps in a job."""
        job_env = dict(self.global_env)
        job_env.update(job.env)

        result = JobResult(
            job_name=job.name,
            success=True,
            step_results=[]
        )

        # Check job-level condition
        if job.condition and not self._evaluate_condition(job.condition, job_env):
            return result  # Skip entire job

        for step in job.steps:
            step_result = self.execute_step(step, job_env)
            result.step_results.append(step_result)
            
            if not step_result.success and not step_result.skipped:
                result.success = False
                break  # Stop on first failure

        return result

    def execute_step(self, step: Step, parent_env: dict) -> StepResult:
        """Execute a single step."""
        step_env = dict(parent_env)
        step_env.update(step.env)

        # Check step condition
        if step.condition:
            if not self._evaluate_condition(step.condition, step_env):
                return StepResult(
                    step_name=step.name,
                    success=True,
                    exit_code=0,
                    output="",
                    skipped=True,
                    skip_reason=f"Condition not met: {step.condition}"
                )

        # Handle 'uses' actions (simulated)
        if step.uses and not step.run:
            return StepResult(
                step_name=step.name,
                success=True,
                exit_code=0,
                output=f"[Simulated] Action: {step.uses}",
                skipped=True,
                skip_reason="External actions are simulated locally"
            )

        # Execute shell command
        if step.run:
            return self._run_command(step.name, step.run, step_env)

        return StepResult(
            step_name=step.name,
            success=True,
            exit_code=0,
            output="No command to execute",
            skipped=True,
            skip_reason="Step has no run command"
        )

    def _run_command(self, step_name: str, command: str, env: dict) -> StepResult:
        """Run a shell command and capture output."""
        # Substitute environment variables in command
        expanded_command = self._expand_variables(command, env)

        try:
            process = subprocess.run(
                expanded_command,
                shell=True,
                capture_output=True,
                text=True,
                env=env,
                cwd=self.working_dir,
                timeout=300  # 5 minute timeout
            )

            return StepResult(
                step_name=step_name,
                success=process.returncode == 0,
                exit_code=process.returncode,
                output=process.stdout,
                error=process.stderr
            )

        except subprocess.TimeoutExpired:
            return StepResult(
                step_name=step_name,
                success=False,
                exit_code=-1,
                output="",
                error="Command timed out after 300 seconds"
            )
        except Exception as e:
            return StepResult(
                step_name=step_name,
                success=False,
                exit_code=-1,
                output="",
                error=str(e)
            )

    def _expand_variables(self, text: str, env: dict) -> str:
        """Expand environment variables in text."""
        result = text
        
        # GitHub Actions style: ${{ env.VAR }} or ${{ github.* }}
        github_pattern = r'\$\{\{\s*env\.(\w+)\s*\}\}'
        result = re.sub(github_pattern, lambda m: env.get(m.group(1), ''), result)
        
        # Standard shell style: $VAR or ${VAR}
        for key, value in env.items():
            result = result.replace(f'${{{key}}}', str(value))
            result = result.replace(f'${key}', str(value))

        return result

    def _evaluate_condition(self, condition: str, env: dict) -> bool:
        """Evaluate a simple condition expression."""
        # Handle common GitHub Actions conditions
        condition = condition.strip()
        
        # always() - always run
        if condition == 'always()':
            return True
        
        # failure() - run on failure (we don't track this yet)
        if condition == 'failure()':
            return False
        
        # success() - run on success (default)
        if condition == 'success()':
            return True

        # Simple equality checks: env.VAR == 'value'
        eq_match = re.match(r"env\.(\w+)\s*==\s*['\"](.+)['\"]", condition)
        if eq_match:
            var_name, expected = eq_match.groups()
            return env.get(var_name) == expected

        # Simple inequality checks: env.VAR != 'value'
        neq_match = re.match(r"env\.(\w+)\s*!=\s*['\"](.+)['\"]", condition)
        if neq_match:
            var_name, expected = neq_match.groups()
            return env.get(var_name) != expected

        # Azure Pipelines: eq(variables['VAR'], 'value')
        azure_eq = re.match(r"eq\(variables\['(\w+)'\],\s*['\"](.+)['\"]\)", condition)
        if azure_eq:
            var_name, expected = azure_eq.groups()
            return env.get(var_name) == expected

        # Default: assume condition is met for unsupported expressions
        return True
