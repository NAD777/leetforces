from xmlrpc.server import SimpleXMLRPCServer
from subprocess import Popen, PIPE, TimeoutExpired, check_output
from yaml import safe_load
from json import dump, load
from typing import Dict, Tuple
from argparse import ArgumentParser
from os import makedirs
from resource import setrlimit, RLIMIT_AS, RLIM_INFINITY
from shlex import split

status_codes = {
    "OK": "OK",   # done
    "RE": "RE",   # done
    "WA": "WA",   # done
    "CE": "CE",   # done
    "MLE": "MLE", # done
    "TLE": "TLE", # done
}


def resolve_compiler(ext: str) -> Dict[str, str]:
    with open("configs/compiler_config.yaml") as file:
        try:
            return safe_load(file)[ext]
        except KeyError:
            raise ValueError("Wrong input file format in configuration.")

   
def run_user_code(exec_string: str, time_limit: float, memory_limit: int, stdin_data: str = '') -> Dict[str, str]:

    MAX_VIRTUAL_MEMORY = int(memory_limit * 1024 * 1024)
    cmd = exec_string
    if stdin_data != '':
        cmd = f"sh run.sh '{stdin_data}' '{exec_string}'"

    prepared = split(cmd)
    proc = Popen(prepared, stdout=PIPE, stdin=PIPE, stderr=PIPE,
                preexec_fn=lambda: setrlimit(RLIMIT_AS, (RLIM_INFINITY, RLIM_INFINITY)))
    try:
        output = proc.communicate()
    except TimeoutExpired:
        output = status_codes["TLE"]

    if output == status_codes["TLE"]:
        result = {
            "error_status" : status_codes["TLE"],
            "output" : ('', ''),
            "max_mem" : -1,
            "time" : -1
        }
        return result

    output_dec = (output[0].decode(), output[1].decode().lower()) #type: ignore
    # If we got right output from /usr/bin/time
    max_mem, real_time = -1, -1
    
    if stdin_data != '':
        max_mem, real_time = output_dec[1].split('\n')[:-1][-1].split()
    if stdin_data != '' and len(output_dec[1].split()) == 2:
        output_dec = (output_dec[0], '')

    result = {
        "output": output_dec,
        "time": int(float(real_time)*1000),
        "max_mem": int(max_mem) // 1024,
        # "max_mem": max_mem,
        "error_status" : None
    }
    print(result)
    return result


def run_tests(submission_id: int, ext: str, source_file: str, test_data: str, task_id: int, filename: str):
    report = {
        "submit_id": int,
        "status": str,
        "test_num": int,
        "memory_used": int,
        "run_time": int,
    }
    report["submit_id"] = submission_id

    config = safe_load(open("configs/solution_config.yaml", 'r'))[f"task_{task_id}"]
    compiler_options = resolve_compiler(ext)
    compiler = compiler_options["compiler_string"]
    ce = compiler_options["ce"]
    time_limit = config["time_limit"]
    memory_limit = config["memory_limit"]

    exec_string = f"{compiler} ./submissions/{filename}"

    makedirs("submissions", exist_ok=True)
    open(f"./submissions/{filename}", "w").write(source_file)

    makedirs("test_data", exist_ok=True)
    dump(test_data, open(f"./test_data/{task_id}.json", "w"))
    tests = load(open(f"./test_data/{task_id}.json", "r"))

    # Check for CE
    input, _ = tests["0"]
    result = run_user_code(exec_string, time_limit, memory_limit, input)
    if ce in result["output"][1]:
        report["test_num"] = 0
        report["status"] = status_codes["CE"]

    for test_num, (input, desired_output) in tests.items():
        result = run_user_code(exec_string, time_limit, memory_limit, input)
        output = result["output"]

        # Check for TLE
        if result["error_status"] == status_codes["TLE"]:
            report["test_num"] = test_num
            report["status"] = status_codes["TLE"]
            break
        
        print(output[1].lower())
        # Check for MLE
        if "memory" in output[1].lower():
            report["test_num"] = test_num
            report["status"] = status_codes["MLE"]
            break

        # Check for RE
        if len(output[1]) > 0:
            report["test_num"] = test_num
            report["status"] = status_codes["RE"]
            break

        # Check for WA
        if output[0] != desired_output[0] and len(output[1]) == 0:
            print(f"{output=}, {desired_output=}")
            report["test_num"] = test_num
            report["status"] = status_codes["WA"]
            break

    # Everything seems OK
    else:
        report["status"] = status_codes["OK"]
        report["test_num"] = -1

    report["memory_used"] = result["max_mem"]
    report["run_time"] = result["time"]

    print(report)
    return report


def generate_tests(config) -> Dict[int, Tuple[str, str]]:
    filename = config["solution_source"]
    ext = filename.split(".")[-1]
    compiler = resolve_compiler(ext)["compiler_string"]
    tests_no = config["tests_no"]
    time_limit = config["time_limit"]
    memory_limit = config["memory_limit"]
    test_data = {}
    for test in range(tests_no):
        input_data = run_user_code(
            f"{compiler} ./solutions/{filename} sample", time_limit, memory_limit)["output"][0]
        output_data = run_user_code(
            f"{compiler} ./solutions/{filename} test", time_limit, memory_limit, input_data)["output"]
        test_data[str(test)] = (input_data, output_data)
    return test_data


def generate_test_data(task_id: int) -> Dict[int, Tuple[str, str]]:
    config = safe_load(open("configs/solution_config.yaml", 'r'))
    gen_details = config[f"task_{task_id}"]
    print(gen_details)
    tests = generate_tests(gen_details)
    dump(tests, open("tests.json", 'w'))
    return tests


def serve(runtime_function):
    with SimpleXMLRPCServer(("0.0.0.0", 31337)) as server:
        server.register_introspection_functions()
        server.register_function(runtime_function)
        server.serve_forever()


if __name__ == '__main__':
    parser = ArgumentParser()
    parser.add_argument("mode", type=str)
    mode = parser.parse_args().mode

    if mode == "generate":
        serve(generate_test_data)
    else:
        serve(run_tests)
