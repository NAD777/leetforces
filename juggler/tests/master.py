from random import randint
#from solution import Solution

import argparse

class Solution:
    def gen_sample(self):
        """Generates a single sample of valid test data and prints it.
        """
        return str()

    def run(self):
        """Runs the master solution
        Input: stdin
        Output: stdout.
        """
        pass


class Task1(Solution):

    # @override
    def gen_sample(self):
        LOWER_BOUNDARY = int(-1e1)
        UPPER_BOUNDARY = int(1e1)
        a = randint(LOWER_BOUNDARY, UPPER_BOUNDARY)
        b = randint(LOWER_BOUNDARY, UPPER_BOUNDARY)
        sample_input = f"{a} {b}"
        print(sample_input)

    # @override
    def run(self):
        print(sum(map(int, input().split())))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("mode")
    mode = parser.parse_args().mode
    task = Task1()
    if mode == 'sample':
        task.gen_sample()
    else:
        task.run()
