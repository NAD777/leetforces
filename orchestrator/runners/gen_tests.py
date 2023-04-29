from xmlrpc.server import SimpleXMLRPCServer
from subprocess import Popen, PIPE
import yaml
import json
from typing import Dict, Tuple


def resolve_compiler(ext: str) -> str:
    with open("configs/compiler_config.yaml") as file:
        try:
            return yaml.safe_load(file)[ext]
        except KeyError:
            raise ValueError("Wrong input file format in configuration.")

def get_output(exec_string: str, stdin_data: str = '') -> str:
    pipe = Popen(exec_string.split(), stdout=PIPE, stdin=PIPE, stderr=PIPE)
    output = pipe.communicate(input=stdin_data.encode('utf-8'))[0]
    return output.decode('utf-8')

def generate_tests(filename: str, tests_no: int) -> Dict[int, Tuple[str, str]]:
    ext = filename.split('.')[-1]
    compiler = resolve_compiler(ext)
    test_data = {}
    for test in range(tests_no):
        input_data = get_output(f'{compiler} ./solutions/{filename} sample')
        output_data = get_output(f'{compiler} ./solutions/{filename} test', input_data)
        test_data[str(test)] = (input_data, output_data)
    return test_data


def generate_test_data(task_id: int) -> bytes:
    file = open("configs/solution_config.yaml", 'r')
    config = yaml.safe_load(file)
    file.close()
    gen_details = config[f"task_{task_id}"]
    tests = generate_tests(gen_details["solution_source"],
                            gen_details["tests_no"])
    test_data = open("tests.json", 'w')
    json.dump(tests, test_data)
    test_data.close()

    test_data = open("tests.json", 'rb').read()
    return test_data


with SimpleXMLRPCServer(('0.0.0.0', 31337)) as server:
    server.register_introspection_functions()
    server.register_function(generate_test_data)
    server.serve_forever()
