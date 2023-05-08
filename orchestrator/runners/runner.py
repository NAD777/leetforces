from xmlrpc.server import SimpleXMLRPCServer
from subprocess import Popen, PIPE, TimeoutExpired, check_output
from yaml import safe_load
from json import dump, load
from typing import Dict, Tuple
from os import makedirs
from resource import setrlimit, RLIMIT_AS, RLIM_INFINITY
from shlex import split


class Runner:

    status_codes = {
        "OK": "OK",
        "RE": "RE",
        "WA": "WA",
        "CE": "CE",
        "MLE": "MLE",
        "TLE": "TLE",
    }

    def resolve_compiler(self, ext: str) -> Dict[str, str]:
        with open("configs/compiler_config.yaml") as file:
            try:
                return safe_load(file)[ext]
            except KeyError:
                raise ValueError("Wrong input file format in configuration.")

    def run_user_code(self, exec_string: str, time_limit: float = 0.0, memory_limit: int = 0, stdin_data: str = '') -> Dict[str, str]:
        print(exec_string)
        print(stdin_data)
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
            output = Runner.status_codes["TLE"]

        if output == Runner.status_codes["TLE"]:
            result = {
                "error_status": Runner.status_codes["TLE"],
                "output": ('', ''),
                "max_mem": -1,
                "time": -1
            }
            return result

        output_dec = (output[0].decode(),          # type: ignore
                      output[1].decode().lower())  # type: ignore
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
            "error_status": None
        }
        print(result)
        return result

    def run_tests(self, submission_id: int, task_id: int, test_details: Dict[str, str]) -> Dict[str, int | str]:
        report = {
            "submit_id": int,
            "status": str,
            "test_num": int,
            "memory_used": int,
            "run_time": int,
        }
        report["submit_id"] = submission_id


        memory_limit = int(test_details["memory_limit"])        #type: ignore
        time_limit = float(test_details["time_limit"])          #type: ignore
        compiler = test_details["compiler"]
        compiler_string = compiler["compiler_string"]           #type: ignore
        ce = compiler["ce"]                                     #type: ignore
        test_data = test_details["test_data"]
        filename = test_details["filename"]
        source_file = test_details["source_file"]

        exec_string = f"{compiler_string} ./submissions/{filename}"

        makedirs("submissions", exist_ok=True)
        open(f"./submissions/{filename}", "w").write(source_file) #type: ignore

        makedirs("test_data", exist_ok=True)
        dump(test_data, open(f"./test_data/{task_id}.json", "w"))
        tests = load(open(f"./test_data/{task_id}.json", "r"))

        # Check for CE
        input, _ = tests["0"]
        result = self.run_user_code(
            exec_string, time_limit, memory_limit, input)

        for test_num, (input, desired_output) in tests.items():
            result = self.run_user_code(
                exec_string=exec_string, time_limit=time_limit, memory_limit=memory_limit, stdin_data=input)
            output = result["output"]

            # Check for CE
            if ce in result["output"][1]:
                report["test_num"] = test_num
                report["status"] = Runner.status_codes["CE"]
                break

            # Check for TLE
            if result["error_status"] == Runner.status_codes["TLE"]:
                report["test_num"] = test_num
                report["status"] = Runner.status_codes["TLE"]
                break

            # Check for MLE
            if "memory" in output[1]:
                report["test_num"] = test_num
                report["status"] = Runner.status_codes["MLE"]
                break

            # Check for RE
            if len(output[1]) > 0:
                report["test_num"] = test_num
                report["status"] = Runner.status_codes["RE"]
                break

            # Check for WA
            if output[0] != desired_output[0] and len(output[1]) == 0:
                print(f"{output=}, {desired_output=}")
                report["test_num"] = test_num
                report["status"] = Runner.status_codes["WA"]
                break

        # Everything seems OK
        else:
            report["status"] = Runner.status_codes["OK"]
            report["test_num"] = -1

        report["memory_used"] = result["max_mem"]
        report["run_time"] = result["time"]

        print(report)
        return report

    def generate_tests(self, config) -> Dict[int, Tuple[str, str]]:
        filename = config["master_filename"]
        with open(f"./solutions/{filename}", "w") as file:
            file.write(config["master_solution"])
        tests_no = config["amount_test"]
        compiler = config["compiler"]
        compiler_string = compiler["compiler_string"]
        ce = compiler["ce"]
        test_data = {}
        for test in range(tests_no):
            input_data = self.run_user_code(
                f"{compiler_string} ./solutions/{filename} sample")["output"][0]
            output_data = self.run_user_code(
                f"{compiler_string} ./solutions/{filename} test", stdin_data=input_data)["output"]
            test_data[str(test)] = (input_data, output_data)

        return test_data

    def generate_test_data(self, gen_details: Dict[str, str]) -> Dict[int, Tuple[str, str]]:
        tests = self.generate_tests(gen_details)
        dump(tests, open("tests.json", 'w'))

        return tests


if __name__ == '__main__':
    with SimpleXMLRPCServer(("0.0.0.0", 31337)) as server:
        server.register_introspection_functions()
        server.register_instance(Runner())
        server.serve_forever()
