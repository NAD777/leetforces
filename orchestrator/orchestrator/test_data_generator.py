import json
import sys

sys.path.append('../../problem_set/master_solutions')

from task_1 import Task1
from solution import Solution

def generate_data(solution: Solution) -> None:
    test_data = open(f"../runners/test_data/task_{solution.task_id}.json", "w")
    for _ in range(solution.tests_no):
        test = {}

        data = solution.gen_sample()
        test['in'] = solution.last_generated_test
        test['out'] = solution.run(*data)

        json.dump(test, test_data)
        test_data.write('\n')


if __name__ == '__main__':
    t1 = Task1()
    generate_data(t1)
