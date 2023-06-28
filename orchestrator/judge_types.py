from typing import NamedTuple, TypedDict, Optional, TypeAlias, Dict
from enum import Enum


class CompilerDetails(TypedDict):
    interpretable: bool
    compiler_string: Optional[str]
    execution_string: str
    ce: str
    default_memory: int


class GenDetails(TypedDict):
    amount_test: int
    master_file: str
    master_filename: str
    compiler: CompilerDetails


class SampleData(NamedTuple):
    sample_in: str
    sample_out: str

TestData: TypeAlias = Dict[str, SampleData]


class TestDetails(TypedDict):
    memory_limit: int
    time_limit: float
    compiler: CompilerDetails
    test_data: TestData
    filename: str
    source_file: str


class StatusCode(str, Enum):
    OK = "OK"
    RE = "RE"
    WA = "WA"
    CE = "CE"
    MLE = "MLE"
    TLE = "TLE"


class Report(TypedDict):
    submission_id: int
    runtime: float
    memory: int
    status: StatusCode
    test_number: int


class Output(NamedTuple):
    stdout: str
    stderr: str


class RunReport(TypedDict):
    error_status: Optional[StatusCode]
    output: Output
    memory_used: int
    runtime: int


class DirtyReport(TypedDict):
    status: StatusCode
    test_number: int
    memory_used: int
    runtime: float


class GeneratorStatus(str, Enum):
    ALREADY_GENERATED = "Already generated"
    SUCCESSFULLY_GENERATED = "Successfully generated"
    GENERATION_ERROR = "Generation error happened"


class RunStatus(str, Enum):
    SUCCESS = "Successfully tested the submission"
    FAILURE = "Failure while testing the user submission"
