"""
Property Test: Pipeline Step Execution
Validates: Requirements 3.8

Property 4: Pipeline Step Execution
For any valid pipeline YAML with shell command steps, the CI/CD simulator SHALL 
execute each step in order and capture the output, with the final result matching 
the expected output of running those commands directly.
"""

import subprocess
import tempfile
import os
from hypothesis import given, strategies as st, settings, assume
from simulator.parser import PipelineParser, Pipeline, Job, Step
from simulator.executor import StepExecutor


# Strategy for generating safe shell commands that produce predictable output
safe_commands = st.sampled_from([
    'echo "hello"',
    'echo "world"',
    'echo "test output"',
    'echo $((1 + 1))',
    'printf "line1\\nline2"',
    'echo "foo bar baz"',
])

# Strategy for generating environment variable names (alphanumeric, starting with letter)
env_var_names = st.text(
    alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    min_size=3,
    max_size=8
)

# Strategy for generating safe environment variable values
env_var_values = st.text(
    alphabet='abcdefghijklmnopqrstuvwxyz0123456789',
    min_size=1,
    max_size=20
)


@given(command=safe_commands)
@settings(max_examples=20, deadline=10000)
def test_step_execution_matches_direct_execution(command: str):
    """
    Property: For any safe shell command, the simulator's output should match
    the output of running the command directly.
    
    **Validates: Requirements 3.8**
    """
    # Run command directly
    direct_result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True
    )
    
    # Run command through simulator
    step = Step(name="test_step", run=command)
    executor = StepExecutor()
    step_result = executor.execute_step(step, dict(os.environ))
    
    # Property: Output should match
    assert step_result.output.strip() == direct_result.stdout.strip(), \
        f"Output mismatch: simulator='{step_result.output.strip()}', direct='{direct_result.stdout.strip()}'"
    
    # Property: Exit code should match
    assert step_result.exit_code == direct_result.returncode, \
        f"Exit code mismatch: simulator={step_result.exit_code}, direct={direct_result.returncode}"
    
    # Property: Success status should match
    assert step_result.success == (direct_result.returncode == 0), \
        f"Success status mismatch"


@given(
    env_name=env_var_names,
    env_value=env_var_values
)
@settings(max_examples=20, deadline=10000)
def test_environment_variable_substitution(env_name: str, env_value: str):
    """
    Property: Environment variables set in the step should be available
    during command execution.
    
    **Validates: Requirements 3.8**
    """
    assume(len(env_name) > 0 and len(env_value) > 0)
    
    command = f'echo "${env_name}"'
    step = Step(
        name="env_test_step",
        run=command,
        env={env_name: env_value}
    )
    
    executor = StepExecutor()
    base_env = dict(os.environ)
    base_env.update(step.env)
    
    step_result = executor.execute_step(step, base_env)
    
    # Property: The output should contain the environment variable value
    assert env_value in step_result.output, \
        f"Environment variable not substituted: expected '{env_value}' in output '{step_result.output}'"


@given(
    commands=st.lists(safe_commands, min_size=1, max_size=5)
)
@settings(max_examples=15, deadline=30000)
def test_multiple_steps_execute_in_order(commands: list):
    """
    Property: Multiple steps in a job should execute in order,
    and all outputs should be captured.
    
    **Validates: Requirements 3.8**
    """
    # Create a job with multiple steps
    steps = [Step(name=f"step_{i}", run=cmd) for i, cmd in enumerate(commands)]
    job = Job(name="test_job", steps=steps)
    
    executor = StepExecutor()
    job_result = executor.execute_job(job)
    
    # Property: Number of step results should match number of steps
    assert len(job_result.step_results) == len(commands), \
        f"Step count mismatch: expected {len(commands)}, got {len(job_result.step_results)}"
    
    # Property: Each step should have executed (not skipped)
    for i, step_result in enumerate(job_result.step_results):
        assert not step_result.skipped, \
            f"Step {i} was unexpectedly skipped"
        assert step_result.success, \
            f"Step {i} failed unexpectedly: {step_result.error}"


def test_conditional_step_skipped_when_condition_false():
    """
    Property: Steps with conditions that evaluate to false should be skipped.
    
    **Validates: Requirements 3.8, 3.9**
    """
    step = Step(
        name="conditional_step",
        run='echo "should not run"',
        condition="env.SKIP_THIS == 'true'"
    )
    
    executor = StepExecutor()
    env = dict(os.environ)
    env['SKIP_THIS'] = 'false'
    
    step_result = executor.execute_step(step, env)
    
    # Property: Step should be skipped
    assert step_result.skipped, "Step should have been skipped due to condition"


def test_conditional_step_runs_when_condition_true():
    """
    Property: Steps with conditions that evaluate to true should execute.
    
    **Validates: Requirements 3.8, 3.9**
    """
    step = Step(
        name="conditional_step",
        run='echo "should run"',
        condition="env.RUN_THIS == 'yes'"
    )
    
    executor = StepExecutor()
    env = dict(os.environ)
    env['RUN_THIS'] = 'yes'
    
    step_result = executor.execute_step(step, env)
    
    # Property: Step should have executed
    assert not step_result.skipped, "Step should not have been skipped"
    assert step_result.success, "Step should have succeeded"
    assert "should run" in step_result.output, "Output should contain expected text"


def test_failing_command_returns_failure():
    """
    Property: Commands that exit with non-zero status should be marked as failed.
    
    **Validates: Requirements 3.8**
    """
    step = Step(
        name="failing_step",
        run='exit 1'
    )
    
    executor = StepExecutor()
    step_result = executor.execute_step(step, dict(os.environ))
    
    # Property: Step should be marked as failed
    assert not step_result.success, "Step should have failed"
    assert step_result.exit_code == 1, f"Exit code should be 1, got {step_result.exit_code}"


def test_job_stops_on_first_failure():
    """
    Property: When a step fails, subsequent steps should not execute.
    
    **Validates: Requirements 3.8**
    """
    steps = [
        Step(name="step_1", run='echo "first"'),
        Step(name="step_2", run='exit 1'),  # This will fail
        Step(name="step_3", run='echo "third"'),  # Should not run
    ]
    job = Job(name="test_job", steps=steps)
    
    executor = StepExecutor()
    job_result = executor.execute_job(job)
    
    # Property: Job should have failed
    assert not job_result.success, "Job should have failed"
    
    # Property: Only first two steps should have results
    assert len(job_result.step_results) == 2, \
        f"Expected 2 step results, got {len(job_result.step_results)}"
    
    # Property: First step succeeded, second failed
    assert job_result.step_results[0].success, "First step should have succeeded"
    assert not job_result.step_results[1].success, "Second step should have failed"
