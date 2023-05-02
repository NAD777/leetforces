import os
from xmlrpc.client import ServerProxy, Fault
from typing import Dict, Tuple
from json import dump, load

class TestRunner:

    task_id: int
    submission_id: int
    extension: str

    def __init__(self, task_id, submission_id, extension):
        self.task_id = task_id
        self.submission_id = submission_id
        self.extension = extension

    # TODO: optimize
    def generate_data(self) -> str:
        path = f"./test_data/task_{self.task_id}.json"
        if os.path.exists(path):
            return f"Test data is already present for {self.task_id=}"

        data = ''
        try:
            node = ServerProxy('http://test_generator:31337')
            data = node.generate_test_data(self.task_id)
        except Fault as err:
            print(err.faultString)
            return "Some error happened"

        if data != '':
            test_data = open(path, 'w')
            dump(data, test_data)

        return f"Test data generated for {self.task_id=}"

    def run(self, filename, source_file)-> Dict[int, Tuple[str, str]]:
        print(self.generate_data())

        try:
            node = ServerProxy('http://runner:31337')
            path = f"./test_data/task_{self.task_id}.json"
            test_data = load(open(path, 'rb'))
            report = node.run_tests(self.submission_id, self.extension, source_file,
                           test_data, self.task_id, filename)  
            return report # type: ignore
        except Fault as err:
            print(err.faultString)
            return {}
        except FileNotFoundError as e:
            print(e)
            return {}
