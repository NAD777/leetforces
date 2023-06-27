from typing import TypedDict
from enum import Enum


class CompilerDetails(TypedDict):
    interpretable: bool
    compilation_string: str | None
    execution_string: str
    ce: str
    default_memory: int

class GenDetails(TypedDict):
    amount_test: int
    master_file: str
    master_filename: str
    compiler: CompilerDetails

class TestData(TypedDict):
    test_id: int
    input_data: str
    output_data: str

class TestDetails(TypedDict):
    memory_limit: int
    time_limit: int
    compiler: CompilerDetails
    test_data: TestData
    filename: str
    source_file: str

class Report(TypedDict):
    submission_id: int
    runtime: float
    memory: int
    # TODO: StatusCode
    status: str
    test_number: int

class DirtyReport(TypedDict):
    # TODO: StatusCode
    status: str
    test_number: int | None
    memory_used: int | None
    runtime: float | None

class GeneratorStatus(str, Enum):
    ALREADY_GENERATED = "Already generated"
    SUCCESSFULLY_GENERATED = "Successfully generated"
    GENERATION_ERROR = "Generation error happened"

class RunStatus(str, Enum):
    SUCCESS = "Successfully tested the submission"
    FAILURE = "Failure while testing the user submission"
