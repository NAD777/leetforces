from xmlrpc.server import SimpleXMLRPCServer
from subprocess import Popen, PIPE, TimeoutExpired
from json import dump, load
from typing import Dict, Tuple, Any
from os import makedirs, chdir
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

    def run_user_code(self, executable: str, configurations: Dict[str, Any], stdin_data: str = '') -> Dict[str, str]:
        try:
            memory_limit = int(configurations["memory_limit"])
            time_limit = float(configurations["time_limit"])
        except:
            memory_limit = 512
            time_limit = 10

        lang_configs = configurations["compiler"]
        execution_string = lang_configs["execution_string"]
        default_memory = int(lang_configs["default_memory"])

        if lang_configs["interpretable"] == 0:
            compiler_string = lang_configs["compiler_string"]
            prepared = split(f"{compiler_string} {executable}")
            Popen(prepared).communicate()

        MAX_VIRTUAL_MEMORY = int((memory_limit + default_memory) * 1024 * 1024)
        
        prepared_executable = executable.split("/")[2]

        if "java" in executable:
            MAX_VIRTUAL_MEMORY = RLIM_INFINITY
            prepared_executable = executable.split("/")[2].split(".")[0]
        
        folder = executable.split('/')[1]
        chdir(f'./{folder}/')
            
        if stdin_data != '':
            cmd = f"sh ../test.sh '{stdin_data}' '{execution_string} {prepared_executable}'"
        else:
            cmd = f"{execution_string} {prepared_executable}"
        
        if stdin_data != '' and "solutions" not in executable:
            cmd = f"sh ../run.sh '{stdin_data}' '{execution_string} {prepared_executable}'"

        prepared = split(cmd)
        proc = Popen(prepared, stdout=PIPE, stdin=PIPE, stderr=PIPE,
                     preexec_fn=lambda: setrlimit(RLIMIT_AS, (MAX_VIRTUAL_MEMORY, RLIM_INFINITY)))

        try:
            output = proc.communicate(timeout=time_limit + 3)
        except TimeoutExpired:
            output = Runner.status_codes["TLE"]

        tle_result = {
            "error_status": Runner.status_codes["TLE"],
            "output": ('', ''),
            "max_mem": -1,
            "time": -1
        }

        if output == Runner.status_codes["TLE"]:
            result = tle_result
            return result

        output_dec = (output[0].decode(),          # type: ignore
                      output[1].decode().lower())  # type: ignore
        # If we got right output from /usr/bin/time
        max_mem, real_time = -1, -1
        if stdin_data != '' and len(output_dec[1].split()) == 2:
            max_mem, real_time = output_dec[1].split('\n')[:-1][-1].split()
            if float(real_time) > time_limit:
                return tle_result

        if stdin_data != '' and len(output_dec[1].split()) == 2:
            output_dec = (output_dec[0], '')

        time = int(float(real_time)*1000) if float(real_time) >= 0 else -1
        max_mem = max(int(max_mem) // 1024 - default_memory, 0)

        result = {
            "output": output_dec,
            "time": time,
            "max_mem": max_mem,
            "error_status": None
        }
        print(result)
        chdir('..')
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

        compiler = test_details["compiler"]
        ce = compiler["ce"]  # type: ignore
        test_data = test_details["test_data"]
        filename = test_details["filename"]
        source_file = test_details["source_file"]

        makedirs("submissions", exist_ok=True)
        executable = f"./submissions/{filename}"
        open(executable, "w").write(source_file)

        makedirs("test_data", exist_ok=True)
        dump(test_data, open(f"./test_data/{task_id}.json", "w"))
        tests = load(open(f"./test_data/{task_id}.json", "r"))

        result = {}
        for test_num, (input, desired_output) in tests.items():
            result = self.run_user_code(
                executable, test_details, stdin_data=input)
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

        makedirs("solutions", exist_ok=True)
        with open(f"./solutions/{filename}", "w") as file:
            file.write(config["master_solution"])
        tests_no = config["amount_test"]

        test_data = {}
        executable = f"./solutions/{filename}"
        for test in range(tests_no):
            input_data = self.run_user_code(
                executable + " sample", config)["output"][0]
            output_data = self.run_user_code(
                executable + " test", config, stdin_data=input_data)["output"]
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
