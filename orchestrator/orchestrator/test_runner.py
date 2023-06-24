from __future__ import annotations

from docker.models.containers import Image
from yaml import safe_load
from xmlrpc.client import ServerProxy, Fault
from json import dump, load
from os import makedirs, environ, path, system
from requests import get
from base64 import b64decode

from typing import Dict, Tuple, Any, cast
from threading import Thread
import dockerapi


REPO_NAME = "codetest_bot"
REPO_NAME_ = "leetforces"
CONTAINERS_MAX = 5
DEBUG = True

class TestRunner:
    """Singleton class wrapper for running code tests
    """
    task_id: int
    submission_id: int
    extension: str
    gen_details: Dict[str, str | Dict[Any, Any]]
    test_details: Dict[str, str | Dict[Any, Any]]

    runner_docker_image: Image | None = None


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

        self.gen_details = {
            "amount_test": task_settings["amount_test"],
            "master_solution": b64decode(task_settings["master_file"])
                                                        .decode("utf-8"),
            "master_filename": task_settings["master_filename"],
            "compiler": {}
        }

        self.test_details = {
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
                ext = cast(str, self.gen_details["master_filename"]) \
                        .split(".")[-1]

                configs = safe_load(file)
                self.gen_details["compiler"] = configs[ext]
                self.test_details["compiler"] = configs[submission_ext]
            except Exception:
                raise ValueError("Unsupported submission format file")

        makedirs("test_data", exist_ok=True)


    def __create_image(self, instance: dockerapi.APIClass) -> Image:
        """Singletone method for returning the Image if it was not already
        built/pulled

        Keyword arguments:
        instance -- instance of dockerapi.APIClass object, used as a wrapper
        of docker api

        Returns:
        Image object"""

        #TODO: add master config parsing

        # do not build/pull if object is already present
        if self.runner_docker_image is not None:
            return self.runner_docker_image

        if DEBUG:
            # build the runner image if in debug mode, i.e. runner source code
            # might change
            self.runner_docker_image = instance.build_image(
                    f"{REPO_NAME_}-runner", ".",
                    "./runners/Dockerfile", True)
        else:
            # pull the runner image from the DockerHub registry for faster
            # execution
            self.runner_docker_image = instance.pull_image(
                    "ghcr.io/nad777/codetest_bot-runner", "latest")
        return self.runner_docker_image


    def __interact_with_container(self,
                                  memory_limit: int,
                                  timeout: float | None = None
                                  ) -> Dict[int, Tuple[str, str]]:
        instance = dockerapi.APIClass()
        self.runner_docker_image = self.__create_image(instance)

        # used for default amount of memory
        memory_magic_number = 50
        memory_limit = 1024 * 1024 * (memory_limit + memory_magic_number)
        container = instance.create_container(f"{REPO_NAME_}-runner",
                memory_limit, "", f"{REPO_NAME}_internal")

        dockerapi.APIClass.start_container(container)

        print(f"Started the container {container.name} with id" + \
                                                       f"{container.short_id}")
        ip = instance.resolve_ip(
                cast(str, container.name), f"{REPO_NAME}_internal")
        print(f"IP address for container {container.name} is {ip}")

        print(f'uri is: http://{ip}:31337')
        with ServerProxy(f'http://{ip}:31337') as node:
            print(node.system.list_methods())
            print(self.gen_details)
            output = []
            th = Thread(target=lambda:
                        output.append(node.generate_test_data(self.gen_details)))
            th.start()
            th.join(timeout)

            # dockerapi.APIClass.stop_container(container)
            print(f"Stopped the running container {container.name}")

        if len(output) == 0:
            return {}
        else:
            return output[0]


    def generate_data(self) -> str:
        """Generate test data through RPC if not already cached.
        Returns:
        Status message for generation
        """

        tests_path = f"./test_data/task_{self.task_id}.json"
        if path.exists(tests_path):
            return f"Test data is already present for {self.task_id=}"

        try:
            memory_limit_mb = int(cast(str, self.test_details["memory_limit"]))

            amount_of_tests =  int(cast(str, self.gen_details["amount_test"]))
            tl_single = float(cast(str, self.test_details["time_limit"]))
            timeout = amount_of_tests * tl_single

            output = self.__interact_with_container(memory_limit_mb, timeout)

        except Fault as err:
            print(err.faultString)
            return "Some error happened"

        if output != {}:
            dump(output, open(tests_path, 'w'))
            return f"Test data generated for {self.task_id=}"
        else:
            return f"Test data was not generated for {self.task_id=}"

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

            report = cast(Dict[int, Tuple[str, str]],
                          node.run_tests(submission_id,
                                         self.task_id,
                                         self.test_details)
                          )
            return report
        except Fault as err:
            print(err.faultString)
            return {}
        except FileNotFoundError as e:
            print(e)
            return {}
