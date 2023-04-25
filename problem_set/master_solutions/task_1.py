from random import randint

from solution import Solution

class Task1(Solution):

    tests_no : int
    last_generated_test : str
    task_id : int

    def __init__(self):
        self.tests_no = 100
        self.task_id = 1

    # @override
    def gen_sample(self):
        LOWER_BOUNDARY=int(-1e9)
        UPPER_BOUNDARY=int(1e9)
        a = randint(LOWER_BOUNDARY, UPPER_BOUNDARY)
        b = randint(UPPER_BOUNDARY, UPPER_BOUNDARY)
        self.last_generated_test = f"{a} {b}"
        return (a, b)

    def run(self, a, b) -> int:
        return sum([a, b])