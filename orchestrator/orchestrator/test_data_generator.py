from __future__ import annotations
import os

from xmlrpc.client import ServerProxy

# it just receives data from the runner generator container, it does not generate anything by itself
class DataGenerator:
    # TODO: optimize
    def generate_data(self, task_id: int, ext: str) -> None:
        path = f"../runners/test_data/task_{task_id}.json"
        if not os.path.exists(path):
            #TODO: add conditional contatiner starting/stopping
            with ServerProxy('http://172.17.0.2:31337') as node:
                data = node.generate_test_data(task_id, ext).data.decode('utf-8')
                test_data = open(path, 'w')
                test_data.write(data)
                test_data.close()