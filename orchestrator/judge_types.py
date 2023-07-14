from typing import NamedTuple, TypedDict, Optional, TypeAlias, Dict, Tuple
from enum import Enum


class CompilerDetails(TypedDict):
    interpretable: bool
    compiler_string: Optional[str]
    execution_string: str
    ce: str
    default_memory: int
    runtime_coef: float


class GenDetails(TypedDict):
    amount_test: int
    master_file: str
    master_filename: str
    compiler: CompilerDetails


SampleData: TypeAlias = Tuple[str, str]

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
    status: StatusCode | str
    test_number: int


class Output(NamedTuple):
    stdout: str
    stderr: str


class RunReport(TypedDict):
    error_status: Optional[StatusCode | str]
    output: Output
    memory_used: int
    runtime: int


class DirtyReport(TypedDict):
    status: StatusCode | str
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
    TIMEOUT_EXPIRED = "Timeout expired while running the user submission"
