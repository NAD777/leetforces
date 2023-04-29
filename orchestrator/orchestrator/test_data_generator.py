from __future__ import annotations
import os

from xmlrpc.client import ServerProxy, Fault

# it just receives data from the runner generator container, it does not generate anything by itself
class DataGenerator:
    # TODO: optimize
    def generate_data(self, task_id: int) -> None:
        path = f"./test_data/task_{task_id}.json"
        if os.path.exists(path):
            return
        
        data = ''
        try:
            node = ServerProxy('http://test_generator:31337')
            data = node.generate_test_data(task_id).data.decode('utf-8')
        except Fault as err:
            print(err.faultString)
        
        test_data = open(path, 'w')
        test_data.write(data)
        test_data.close()