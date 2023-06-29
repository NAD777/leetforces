from xmlrpc.server import SimpleXMLRPCServer
from subprocess import Popen, PIPE, TimeoutExpired
from json import dump, load
from typing import Dict, Any, cast
from os import makedirs, chdir
from resource import setrlimit, RLIMIT_AS, RLIM_INFINITY
from shlex import split

from logging import debug, info, basicConfig
from logging import DEBUG as _DEBUG

import judge_types

DEBUG = False # change this if needed

if DEBUG:
    basicConfig(level=_DEBUG)

class Runner:
    """Class that is actually responsible for test running and generation"""

    def _run_user_code(self,
            executable: str,
            configurations: judge_types.GenDetails | judge_types.TestDetails,
            stdin_data: str = ''
            ) -> judge_types.RunReport:
        """Execute user code

        Keyword arguments:
        executable      -- name of the executable
        configurations  -- Python `dict` object with configurations
        stdin_data      -- input data for the executable

        Returns:
        Python dict object with the following structure

        report: judge_types.RunReport = {
            "error_status": judge_types.StatusCode,
            "output": judge_types.Output,
            "memory_used": int,
            "runtime": int
        }
        """

        if "memory_limit" in configurations.keys():
            configurations = cast(judge_types.TestDetails, configurations)

            debug(configurations)

            memory_limit = configurations["memory_limit"]
            time_limit = configurations["time_limit"]
        else:
            memory_limit = 1024
            time_limit = 100

        lang_configs = configurations["compiler"]
        execution_string = lang_configs["execution_string"]
        default_memory = lang_configs["default_memory"]

        if lang_configs["interpretable"] == 0:
            compiler_string = lang_configs["compiler_string"]
            prepared = split(f"{compiler_string} {executable}")
            Popen(prepared).communicate()

        prepared_executable = executable.split("/")[2]

        if "java" in executable:
            prepared_executable = executable.split("/")[2].split(".")[0]

        folder = executable.split('/')[1]
        chdir(f'./{folder}/')

        if stdin_data != '':
            cmd = f"sh ../test.sh '{stdin_data}' '{execution_string} " + \
                                                     f"{prepared_executable}'"
        else:
            cmd = f"{execution_string} {prepared_executable}"

        if stdin_data != '' and "solutions" not in executable:
            cmd = f"sh ../run.sh '{stdin_data}' '{execution_string} " + \
                                                     f"{prepared_executable}'"

        prepared = split(cmd)
        proc = Popen(prepared, stdout=PIPE, stdin=PIPE, stderr=PIPE,
                     preexec_fn=lambda: setrlimit(RLIMIT_AS,
                                        (RLIM_INFINITY, RLIM_INFINITY)))

        report: judge_types.RunReport = {
            "error_status": None,
            "output": judge_types.Output("", ""),
            "memory_used": -1,
            "runtime": -1
        }

        try:
            output = proc.communicate(timeout=time_limit + 3)
        except TimeoutExpired:
            report["error_status"] = judge_types.StatusCode.TLE
            return report

        output_dec = (output[0].decode(),
                      output[1].decode().lower())
        debug(output_dec)
        # If we got right output from /usr/bin/time
        max_mem, real_time = -1, -1
        if stdin_data != '' and len(output_dec[1].split()) == 2:
            max_mem, real_time = map(float,
                                    output_dec[1].split('\n')[:-1][-1].split())
            max_mem = max(int(max_mem) // 1024 - default_memory, 0)
            if real_time > time_limit:
                report["error_status"] = judge_types.StatusCode.TLE
                return report
            if max_mem > memory_limit:
                report["error_status"] = judge_types.StatusCode.MLE
                return report

        if stdin_data != '' and len(output_dec[1].split()) == 2:
            output_dec = (output_dec[0], '')

        time = int(float(real_time)*1000) if float(real_time) >= 0 else -1

        report["output"] = judge_types.Output(*output_dec)
        report["runtime"] = time
        report["memory_used"] = max_mem
        report["error_status"] = judge_types.StatusCode.OK

        info(report)

        chdir('..')
        return report

    def run_tests(self,
                  test_details: judge_types.TestDetails
                  ) -> judge_types.DirtyReport:
        """Wrapper function for running user code. Called through RPC.

        Keyword arguments:
        test_details    -- Python dict object with configurations

        Returns:
        Python dictionary containing report for running the user submission
        with the following structure:

        report = {
            "status": str,
            "test_number": int,
            "memory_used": int,
            "run_time": int
        }"""

        report: judge_types.DirtyReport = {
            "status": judge_types.StatusCode.OK,
            "test_number": -1,
            "memory_used": -1,
            "runtime": -1,
        }

        compiler = cast(Dict[str, str | Any], test_details["compiler"])
        ce = compiler["ce"]
        test_data = test_details["test_data"]
        filename = test_details["filename"]
        source_file = test_details["source_file"]

        makedirs("submissions", exist_ok=True)
        executable = f"./submissions/{filename}"
        open(executable, "w").write(source_file)

        makedirs("test_data", exist_ok=True)
        dump(test_data, open(f"./test_data/tests.json", "w"))
        tests = load(open(f"./test_data/tests.json", "r"))

        info(f"{tests=}")

        result = {}
        for test_number, (sample_in, desired_output) in tests.items():
            result = self._run_user_code(
                executable, test_details, stdin_data=sample_in)
            output = result["output"]

            # Check for CE
            if ce in result["output"].stderr:
                report["test_number"] = test_number
                report["status"] = judge_types.StatusCode.CE
                break

            # Check for TLE
            if result["error_status"] == judge_types.StatusCode.TLE:
                report["test_number"] = test_number
                report["status"] = judge_types.StatusCode.TLE
                break

            # Check for MLE
            if result["error_status"] == judge_types.StatusCode.MLE or \
                                                "memory" in output.stderr:
                report["test_number"] = test_number
                report["status"] = judge_types.StatusCode.MLE
                break

            # Check for RE
            if len(output.stderr) > 0:
                report["test_number"] = test_number
                report["status"] = judge_types.StatusCode.RE
                break

            # Check for WA
            if output.stdout != desired_output:
                info(f"{output.stdout=}, {desired_output=}")
                report["test_number"] = test_number
                report["status"] = judge_types.StatusCode.WA
                break

        # Everything seems OK
        else:
            report["status"] = judge_types.StatusCode.OK
            report["test_number"] = -1

        report["memory_used"] = result["memory_used"]
        report["runtime"] = result["runtime"]
        report["status"] = report["status"].value

        info(report)
        return report

    def _generate_tests(self,
                       config : judge_types.GenDetails
                       ) -> judge_types.TestData:
        """Generate tests according to the configuration details

        Keyword arguments:
        config -- configuration details

        Returns:
        Python dictionary containing sample input and output data"""

        filename = config["master_filename"]

        makedirs("solutions", exist_ok=True)
        with open(f"./solutions/{filename}", "w") as file:
            file.write(config["master_file"])
        tests_no = config["amount_test"]

        test_data: judge_types.TestData = {}
        executable = f"./solutions/{filename}"
        for test in range(int(tests_no)):
            input_data = self._run_user_code(executable + " sample",
                                            config)["output"].stdout

            output_data = self._run_user_code(executable + " test",
                                        config,
                                        stdin_data=input_data)["output"].stdout
            test_data[str(test)] = (input_data, output_data)

        return test_data

    def generate_test_data(self,
                           gen_details: judge_types.GenDetails
                           ) -> judge_types.TestData:
        """Wrapper function that is called from through RPC

        Keyword arguments:
        gen_details -- Python dict object configuration for test generation

        Returns:
        Python dictionary containing sample input and output data"""

        tests = self._generate_tests(gen_details)
        dump(tests, open("tests.json", 'w'))

        return tests


if __name__ == '__main__':
    with SimpleXMLRPCServer(("0.0.0.0", 31337)) as server:
        server.register_introspection_functions()
        server.register_instance(Runner())
        server.serve_forever()
