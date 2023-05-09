import requests

url = 'http://172.18.0.4:5000/run'
filename = 'invalid.py'
file = open(filename, 'rb')
task_id = 1
extension = 'py'
body = {
    "submission_id": 12,
    "source_file": file.read(),
    "task_id": task_id,
    "extension": extension,
    "file_name": filename
}
response = requests.post(url, json=body)
