"""YAML parser for GitHub Actions and Azure Pipelines configurations."""

import yaml
from dataclasses import dataclass, field
from typing import Optional
from pathlib import Path


@dataclass
class Step:
    """Represents a single step in a pipeline."""
    name: str
    run: Optional[str] = None
    uses: Optional[str] = None
    env: dict = field(default_factory=dict)
    condition: Optional[str] = None
    with_args: dict = field(default_factory=dict)


@dataclass
class Job:
    """Represents a job containing multiple steps."""
    name: str
    steps: list[Step] = field(default_factory=list)
    env: dict = field(default_factory=dict)
    needs: list[str] = field(default_factory=list)
    condition: Optional[str] = None


@dataclass
class Stage:
    """Represents a stage containing multiple jobs (Azure Pipelines)."""
    name: str
    jobs: list[Job] = field(default_factory=list)
    condition: Optional[str] = None


@dataclass
class Pipeline:
    """Represents a parsed pipeline configuration."""
    name: str
    pipeline_type: str  # 'github' or 'azure'
    env: dict = field(default_factory=dict)
    jobs: list[Job] = field(default_factory=list)
    stages: list[Stage] = field(default_factory=list)
    raw_yaml: dict = field(default_factory=dict)


class PipelineParser:
    """Parser for CI/CD pipeline YAML files."""

    def parse_file(self, filepath: str, pipeline_type: str = "github") -> Pipeline:
        """Parse a pipeline YAML file."""
        with open(filepath, 'r') as f:
            content = yaml.safe_load(f)
        return self.parse(content, pipeline_type)

    def parse(self, content: dict, pipeline_type: str = "github") -> Pipeline:
        """Parse pipeline content based on type."""
        if pipeline_type == "github":
            return self._parse_github_actions(content)
        elif pipeline_type == "azure":
            return self._parse_azure_pipelines(content)
        else:
            raise ValueError(f"Unsupported pipeline type: {pipeline_type}")

    def _parse_github_actions(self, content: dict) -> Pipeline:
        """Parse GitHub Actions workflow YAML."""
        pipeline = Pipeline(
            name=content.get('name', 'Unnamed Workflow'),
            pipeline_type='github',
            env=content.get('env', {}),
            raw_yaml=content
        )

        jobs_data = content.get('jobs', {})
        for job_id, job_data in jobs_data.items():
            job = self._parse_github_job(job_id, job_data)
            pipeline.jobs.append(job)

        return pipeline

    def _parse_github_job(self, job_id: str, job_data: dict) -> Job:
        """Parse a GitHub Actions job."""
        needs = job_data.get('needs', [])
        if isinstance(needs, str):
            needs = [needs]

        job = Job(
            name=job_id,
            env=job_data.get('env', {}),
            needs=needs,
            condition=job_data.get('if')
        )

        for step_data in job_data.get('steps', []):
            step = self._parse_github_step(step_data)
            job.steps.append(step)

        return job

    def _parse_github_step(self, step_data: dict) -> Step:
        """Parse a GitHub Actions step."""
        return Step(
            name=step_data.get('name', 'Unnamed Step'),
            run=step_data.get('run'),
            uses=step_data.get('uses'),
            env=step_data.get('env', {}),
            condition=step_data.get('if'),
            with_args=step_data.get('with', {})
        )

    def _parse_azure_pipelines(self, content: dict) -> Pipeline:
        """Parse Azure Pipelines YAML."""
        pipeline = Pipeline(
            name=content.get('name', 'Unnamed Pipeline'),
            pipeline_type='azure',
            env=content.get('variables', {}),
            raw_yaml=content
        )

        # Azure Pipelines can have stages or direct jobs
        if 'stages' in content:
            for stage_data in content['stages']:
                stage = self._parse_azure_stage(stage_data)
                pipeline.stages.append(stage)
        elif 'jobs' in content:
            for job_data in content['jobs']:
                job = self._parse_azure_job(job_data)
                pipeline.jobs.append(job)
        elif 'steps' in content:
            # Simple pipeline with just steps
            job = Job(name='default', steps=[])
            for step_data in content['steps']:
                step = self._parse_azure_step(step_data)
                job.steps.append(step)
            pipeline.jobs.append(job)

        return pipeline

    def _parse_azure_stage(self, stage_data: dict) -> Stage:
        """Parse an Azure Pipelines stage."""
        stage = Stage(
            name=stage_data.get('stage', 'Unnamed Stage'),
            condition=stage_data.get('condition')
        )

        for job_data in stage_data.get('jobs', []):
            job = self._parse_azure_job(job_data)
            stage.jobs.append(job)

        return stage

    def _parse_azure_job(self, job_data: dict) -> Job:
        """Parse an Azure Pipelines job."""
        depends_on = job_data.get('dependsOn', [])
        if isinstance(depends_on, str):
            depends_on = [depends_on]

        job = Job(
            name=job_data.get('job', 'Unnamed Job'),
            env=job_data.get('variables', {}),
            needs=depends_on,
            condition=job_data.get('condition')
        )

        for step_data in job_data.get('steps', []):
            step = self._parse_azure_step(step_data)
            job.steps.append(step)

        return job

    def _parse_azure_step(self, step_data: dict) -> Step:
        """Parse an Azure Pipelines step."""
        # Azure uses 'script' or 'bash' for shell commands
        run_cmd = step_data.get('script') or step_data.get('bash')
        
        return Step(
            name=step_data.get('displayName', step_data.get('name', 'Unnamed Step')),
            run=run_cmd,
            uses=step_data.get('task'),
            env=step_data.get('env', {}),
            condition=step_data.get('condition')
        )
