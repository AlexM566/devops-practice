"""CLI interface for CI/CD pipeline simulator."""

import click
import subprocess
import sys
from pathlib import Path
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich import print as rprint

from .parser import PipelineParser
from .executor import StepExecutor

console = Console()


@click.group()
@click.version_option(version='1.0.0')
def cli():
    """CI/CD Pipeline Simulator - Parse and execute pipelines locally."""
    pass


@cli.command()
@click.argument('filepath', type=click.Path(exists=True))
@click.option('--type', '-t', 'pipeline_type', 
              type=click.Choice(['github', 'azure']), 
              default='github',
              help='Pipeline type (github or azure)')
def validate(filepath: str, pipeline_type: str):
    """Validate a pipeline YAML file."""
    console.print(f"\n[bold blue]Validating:[/bold blue] {filepath}")
    console.print(f"[dim]Pipeline type: {pipeline_type}[/dim]\n")

    # Run yamllint first
    console.print("[yellow]Running yamllint...[/yellow]")
    result = subprocess.run(
        ['yamllint', '-d', 'relaxed', filepath],
        capture_output=True,
        text=True
    )
    
    if result.returncode != 0:
        console.print("[red]✗ YAML lint errors:[/red]")
        console.print(result.stdout or result.stderr)
        sys.exit(1)
    
    console.print("[green]✓ YAML syntax valid[/green]\n")

    # Parse the pipeline
    try:
        parser = PipelineParser()
        pipeline = parser.parse_file(filepath, pipeline_type)
        
        console.print(f"[green]✓ Pipeline parsed successfully[/green]")
        console.print(f"  Name: {pipeline.name}")
        
        if pipeline.stages:
            console.print(f"  Stages: {len(pipeline.stages)}")
            for stage in pipeline.stages:
                console.print(f"    - {stage.name} ({len(stage.jobs)} jobs)")
        else:
            console.print(f"  Jobs: {len(pipeline.jobs)}")
            for job in pipeline.jobs:
                console.print(f"    - {job.name} ({len(job.steps)} steps)")

        console.print("\n[bold green]✓ Validation passed[/bold green]")

    except Exception as e:
        console.print(f"[red]✗ Parse error: {e}[/red]")
        sys.exit(1)


@cli.command()
@click.argument('filepath', type=click.Path(exists=True))
@click.option('--type', '-t', 'pipeline_type',
              type=click.Choice(['github', 'azure']),
              default='github',
              help='Pipeline type (github or azure)')
@click.option('--job', '-j', 'job_filter',
              default=None,
              help='Run only a specific job')
@click.option('--workdir', '-w', 'working_dir',
              default=None,
              help='Working directory for command execution')
def run(filepath: str, pipeline_type: str, job_filter: str, working_dir: str):
    """Run a pipeline locally."""
    console.print(f"\n[bold blue]Running pipeline:[/bold blue] {filepath}")
    console.print(f"[dim]Pipeline type: {pipeline_type}[/dim]")
    if job_filter:
        console.print(f"[dim]Job filter: {job_filter}[/dim]")
    console.print()

    # Parse the pipeline
    try:
        parser = PipelineParser()
        pipeline = parser.parse_file(filepath, pipeline_type)
    except Exception as e:
        console.print(f"[red]✗ Parse error: {e}[/red]")
        sys.exit(1)

    # Execute the pipeline
    executor = StepExecutor(working_dir=working_dir)
    result = executor.execute_pipeline(pipeline, job_filter=job_filter)

    # Display results
    _display_results(result)

    if not result.success:
        sys.exit(1)


def _display_results(result):
    """Display pipeline execution results."""
    status_icon = "[green]✓[/green]" if result.success else "[red]✗[/red]"
    console.print(f"\n{status_icon} [bold]Pipeline: {result.pipeline_name}[/bold]")

    for job_result in result.job_results:
        job_icon = "[green]✓[/green]" if job_result.success else "[red]✗[/red]"
        console.print(f"\n  {job_icon} [bold]Job: {job_result.job_name}[/bold]")

        table = Table(show_header=True, header_style="bold")
        table.add_column("Step", style="cyan")
        table.add_column("Status", justify="center")
        table.add_column("Output", overflow="fold")

        for step_result in job_result.step_results:
            if step_result.skipped:
                status = "[yellow]SKIPPED[/yellow]"
                output = step_result.skip_reason
            elif step_result.success:
                status = "[green]PASS[/green]"
                output = step_result.output[:200] if step_result.output else "-"
            else:
                status = "[red]FAIL[/red]"
                output = step_result.error or step_result.output[:200]

            table.add_row(step_result.step_name, status, output.strip())

        console.print(table)

    # Summary
    total_jobs = len(result.job_results)
    passed_jobs = sum(1 for j in result.job_results if j.success)
    
    console.print(f"\n[bold]Summary:[/bold] {passed_jobs}/{total_jobs} jobs passed")
    
    if result.success:
        console.print("[bold green]Pipeline completed successfully![/bold green]")
    else:
        console.print("[bold red]Pipeline failed![/bold red]")


@cli.command()
@click.argument('filepath', type=click.Path(exists=True))
@click.option('--type', '-t', 'pipeline_type',
              type=click.Choice(['github', 'azure']),
              default='github',
              help='Pipeline type (github or azure)')
def show(filepath: str, pipeline_type: str):
    """Show pipeline structure without executing."""
    parser = PipelineParser()
    
    try:
        pipeline = parser.parse_file(filepath, pipeline_type)
    except Exception as e:
        console.print(f"[red]✗ Parse error: {e}[/red]")
        sys.exit(1)

    console.print(Panel(f"[bold]{pipeline.name}[/bold]\nType: {pipeline_type}"))

    if pipeline.env:
        console.print("\n[bold]Environment Variables:[/bold]")
        for key, value in pipeline.env.items():
            console.print(f"  {key}={value}")

    if pipeline.stages:
        for stage in pipeline.stages:
            console.print(f"\n[bold cyan]Stage: {stage.name}[/bold cyan]")
            if stage.condition:
                console.print(f"  [dim]Condition: {stage.condition}[/dim]")
            for job in stage.jobs:
                _show_job(job)
    else:
        for job in pipeline.jobs:
            _show_job(job)


def _show_job(job):
    """Display job details."""
    console.print(f"\n  [bold yellow]Job: {job.name}[/bold yellow]")
    if job.needs:
        console.print(f"    [dim]Depends on: {', '.join(job.needs)}[/dim]")
    if job.condition:
        console.print(f"    [dim]Condition: {job.condition}[/dim]")
    
    for i, step in enumerate(job.steps, 1):
        step_type = "run" if step.run else "uses" if step.uses else "?"
        console.print(f"    {i}. {step.name} [{step_type}]")
        if step.condition:
            console.print(f"       [dim]if: {step.condition}[/dim]")


def main():
    """Entry point for the CLI."""
    cli()


if __name__ == '__main__':
    main()
