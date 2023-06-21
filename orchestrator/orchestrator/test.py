from dockerapi import APIClass

instance = APIClass()

instance.build_image("runner", "../../",
                     "./orchestrator/runners/Dockerfile", True)
instance.create_container("runner", 1024*1024*300,
                          "python -u runner.py")
instance.start_container()
