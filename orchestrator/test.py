from dockerapi import APIClass

instance = APIClass()

image_built = instance.build_image("runner", "../../", "./orchestrator/runners/Dockerfile", True)
image_pulled = instance.pull_image("ghcr.io/nad777/codetest_bot-runner", "latest")

con_built = instance.create_container("runner", 1024*1024*300, "python -u runner.py")
con_pulled = instance.create_container("codetest_bot-runner", 1024*1024*30, "python -u runner.py")

APIClass.start_container(con_built)
APIClass.start_container(con_pulled)
