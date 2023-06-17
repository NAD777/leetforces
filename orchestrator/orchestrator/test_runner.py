from yaml import safe_load
from xmlrpc.client import ServerProxy, Fault
from typing import Dict, Tuple
from json import dump, load
from os import makedirs, environ, path
from requests import get
from base64 import b64decode


class TestRunner:
    """Class wrapper for running code tests
    """
    task_id: int
    submission_id: int
    extension: str
    gen_details: Dict[str, str]
    test_details: Dict[str, str]

    def __init__(self,
                 task_id : int,
                 submission_ext : str
                 ) -> None:
        """Constructor method for TestRunner class

        Keyword arguments:
        task_id -- id of the task to run
        submission_ext -- file extension of the user submission
        """

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

        if task_settings["code"] != 0:
            raise ValueError(task_settings["status"])

        self.gen_details = {                                    # type: ignore
            "amount_test": task_settings["amount_test"],
            "master_solution": b64decode(task_settings["master_file"])
                                                        .decode("utf-8"),
            "master_filename": task_settings["master_filename"],
            "compiler": {}
        }

        self.test_details = {                                   # type: ignore
            "memory_limit": task_settings["memory_limit"],
            "time_limit": task_settings["time_limit"],
            "compiler": {},
            "test_data": {},
            "filename": '',
            "source_file": ''
        }

        self.task_id = task_id

        with open("configs/compiler_config.yaml") as file:
            try:
                ext = self.gen_details["master_filename"] \
                        .split(".")[-1]    # type: ignore

                configs = safe_load(file)
                self.gen_details["compiler"] = configs[ext]
                self.test_details["compiler"] = configs[submission_ext]
            except Exception:
                raise ValueError("Unsupported submission format file")

        makedirs("test_data", exist_ok=True)

    def generate_data(self) -> str:
        """Generate test data through RPC if not already cached.
        Returns:
        Status message for generation
        """
        tests_path = f"./test_data/task_{self.task_id}.json"
        if path.exists(tests_path):
            return f"Test data is already present for {self.task_id=}"

        data = ''
        try:
            #TODO add conditional container start/stop here
            node = ServerProxy('http://test_generator:31337')
            print(self.gen_details)
            data = node.generate_test_data(self.gen_details)
        except Fault as err:
            print(err.faultString)
            return "Some error happened"

        if data != '':
            dump(data, open(tests_path, 'w'))

        return f"Test data generated for {self.task_id=}"

    def run(self,
            submission_id : int,
            filename : str,
            source_file : str
            )  -> Dict[int, Tuple[str, str]]:
        """Run the tests through the RPC.

        Keyword arguments:
        submission_id -- unique submission number (id) from the user
        filename -- name of the submitted file. Required for compiling some
        languages.
        source_file -- actual source code of the file to compile/run

        Returns:
        report in the format
        report = {
            "submit_id": int,
            "status": str,
            "test_num": int,
            "memory_used": int,
            "run_time": int
        }
        if no exceptions were caught, empty Python dict otherwise"""
        print(self.generate_data())

        try:
            node = ServerProxy('http://runner:31337')
            tests_path = f"./test_data/task_{self.task_id}.json"

            self.test_details["test_data"] = load(open(tests_path, 'rb'))
            self.test_details["filename"] = filename
            self.test_details["source_file"] = source_file

            report = node.run_tests(
                submission_id, self.task_id, self.test_details)
            return report  # type: ignore
        except Fault as err:
            print(err.faultString)
            return {}
        except FileNotFoundError as e:
            print(e)
            return {}
