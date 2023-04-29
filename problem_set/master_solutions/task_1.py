from random import randint
from solution import Solution

import argparse

class Task1(Solution):

    tests_no: int
    last_generated_test: str
    task_id: int

    def __init__(self):
        self.tests_no = 100
        self.task_id = 1

    # @override
    def gen_sample(self):
        LOWER_BOUNDARY = int(-1e9)
        UPPER_BOUNDARY = int(1e9)
        a = randint(LOWER_BOUNDARY, UPPER_BOUNDARY)
        b = randint(LOWER_BOUNDARY, UPPER_BOUNDARY)
        sample_input = f"{a} {b}"
        print(sample_input)

    def run(self):
        print(sum(map(int, input().split())))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("mode", type=int)
    mode = parser.parse_args().mode
    task = Task1()
    if mode == 0:
        task.gen_sample()
    else:
        task.run()