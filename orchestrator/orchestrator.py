from __future__ import annotations

from docker.models.containers import Image
from yaml import safe_load
from xmlrpc.client import ServerProxy, Fault
from json import dump, load
from os import makedirs, environ, path, walk
from requests import get
from base64 import b64decode

from decorators import inside_container
import judge_types

DEBUG = True

TRANSPORT_OVERHEAD = 0.1

class Orchestrator:
    """Class for managing and interacting with judge sandboxes
    """
    task_id: int
    submission_id: int
    extension: str
    gen_details: judge_types.GenDetails
    test_details: judge_types.TestDetails

    runner_docker_image: Image | None = None
    dirty_report: judge_types.DirtyReport
    tests: judge_types.TestData

    def __init__(self,
                 task_id : int,
                 submission_ext : str
                 ) -> None:
        """Constructor method for TestRunner class

        Keyword arguments:
        task_id -- id of the task to run
        submission_ext -- file extension of the user submission
        """

        # TODO: correctly parse all responses
        JUGGLER = environ["JUGGLER"]
        resp = get(f"{JUGGLER}/get_task_info", params={"task_id": task_id})

        try:
            task_settings = resp.json()
        except Exception as e:
            print(e)
            raise ValueError(
                "Exception has occured while trying to retrieve the \
                        task configurations")

        assert task_settings is not None

        self.task_id = task_id
        self.tests = None


        with open("configs/compiler_config.yaml") as file:
            try:
                ext = task_settings["master_filename"].split(".")[-1]

                configs = safe_load(file)
                gen_compiler_details: judge_types.CompilerDetails = configs[ext]
                judge_compiler_details: judge_types.CompilerDetails = \
                                                    configs[submission_ext]
                self.gen_details = {
                    "compiler": gen_compiler_details,
                    "amount_test": 0,
                    "master_file": "",
                    "master_filename": ""
                }
                self.test_details = {
                        "compiler": judge_compiler_details,
                        "filename": "",
                        "test_data": {},
                        "time_limit": 0.0,
                        "source_file": "",
                        "memory_limit": 0
                }
                self.test_details["compiler"] = judge_compiler_details
            except Exception as e:
                print(e)
                raise ValueError("Unsupported submission format file")

        # generate
        self.gen_details["amount_test"] = task_settings["amount_test"]
        self.gen_details["master_file"] = \
                        b64decode(task_settings["master_file"]).decode("utf-8")
        self.gen_details["master_filename"] = task_settings["master_filename"]

        # test
        self.test_details["memory_limit"] = task_settings["memory_limit"]
        self.test_details["time_limit"] = task_settings["time_limit"]

        makedirs("test_data", exist_ok=True)

    def clean_report(self) -> judge_types.Report:
        report: judge_types.Report = {
                "submission_id": self.submission_id,
                "runtime": self.dirty_report["runtime"],
                "memory": self.dirty_report["memory_used"],
                "status": self.dirty_report["status"],
                "test_number": self.dirty_report["test_number"]
                }

        return report

    @inside_container
    def rpc_generate(self, ip='127.0.0.1') -> judge_types.GeneratorStatus:

        memory_limit_mb = self.test_details["memory_limit"]
        amount_of_tests = self.gen_details["amount_test"]
        tl_single = self.test_details["time_limit"]
        timeout = amount_of_tests * (tl_single + TRANSPORT_OVERHEAD)

        tests_path = f"./test_data/task_{self.task_id}.json"
        if path.exists(tests_path):
            return judge_types.GeneratorStatus.ALREADY_GENERATED

        try:
            node = ServerProxy(f"http://{ip}:31337")
            self.tests = \
                    node.generate_test_data(self.gen_details)
            dump(self.tests, open(tests_path, "w"))
            return judge_types.GeneratorStatus.SUCCESSFULLY_GENERATED

        except Fault as e:
            print(e)
            return judge_types.GeneratorStatus.GENERATION_ERROR


    @inside_container
    def rpc_run(self, ip='') -> judge_types.RunStatus:

        # TODO: check for container memory consumption
        memory_limit_mb = self.test_details["memory_limit"]
        amount_of_tests = self.gen_details["amount_test"]
        tl_single = self.test_details["time_limit"]
        timeout = amount_of_tests * (tl_single + TRANSPORT_OVERHEAD)

        if self.tests is None:
            tests_path = f"./test_data/task_{self.task_id}.json"
            self.tests = load(open(tests_path, 'rb'))

        self.test_details["test_data"] = self.tests

        try:
            node = ServerProxy(f"http://{ip}:31337")
            self.dirty_report: judge_types.DirtyReport = \
                            node.run_tests(self.test_details)
            return judge_types.RunStatus.SUCCESS

        except Fault as e:
            print(e)
            return judge_types.RunStatus.FAILURE


    def run(self,
            submission_id: int,
            filename: str,
            source_file: str,
            ) -> judge_types.Report:

        self.submission_id = submission_id
        self.test_details["filename"] = filename
        self.test_details["source_file"] = source_file

        self.rpc_generate()
        self.rpc_run()

        report = self.clean_report()
        return report
