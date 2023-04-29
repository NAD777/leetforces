import requests

url = 'http://127.0.0.1:5000/run'
file = open('valid.py', 'rb')
task_id = 1
extension = 'py'
body = {
    "submission_id": 12, 
    "source_file": file.read(),
    "task_id" : task_id,
    "extension" : extension,
}
response = requests.post(url, json=body)