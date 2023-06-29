from os import environ
from docker.models.containers import Image
from typing import cast
from time import sleep

import dockerapi

_runner_docker_image: Image | None = None

PROJECT_NAME = environ["PROJECT_NAME"]
# TODO: parse _CONTAINERS_MAX from config file somehow
_CONTAINERS_MAX = 5
_CURRENT_CONTAINERS = 0
_WAIT_TIME = 1
DEBUG = environ["DEBUG"]


#TODO: debug and run configurations
def _create_image(instance: dockerapi.APIClass,
                  PROJECT_NAME: str
                  ) -> Image:
    """Singletone method for returning the Image if it was not already
    built/pulled

    Keyword arguments:
    instance        -- instance of dockerapi.APIClass object, used as a wrapper
    of docker api
    PROJECT_NAME    -- name of the project the main dockerfile is located

    Returns:
    Image object"""

    global _runner_docker_image

    #TODO: add master config parsing
    # and/or these parse these configs from upper stack layers

    _runner_docker_image = dockerapi.APIClass() \
                                    .get_image(f"{PROJECT_NAME}-runner")

    # do not build/pull if object is already present
    if not DEBUG and _runner_docker_image is not None:
        return _runner_docker_image

    if DEBUG:
        # build the runner image if in debug mode, i.e. with assumption
        # that the runner source code might have changed
        _runner_docker_image = instance.build_image(
                f"{PROJECT_NAME}-runner", ".",
                "./runners/runner.Dockerfile", False)
    else:
        # pull the runner image from the DockerHub registry for faster
        # execution
        _runner_docker_image = instance.pull_image(
                "ghcr.io/nad777/codetest_bot-runner", "latest")
    return _runner_docker_image

# container_interactor accepts str with ip address and returns T
def inside_container(_func=None, *,
                     memory_limit: str = "1g",
                     retries: int = 10):
    """Decorator function. Create the container and execute `_func` inside it.
    `_func` must accept the `ip` parameter, which determines the ip of the
    created container.

    Keyword arguments:
    memory_limit    -- memory limit of the created container
    retries         -- number of retries to make the connection with the
        container. If you have slow PC, increase this number accordingly."""

    def decorator_container(container_interactor):
        def wrapper(*args, **kwargs):

            global _CURRENT_CONTAINERS

            instance = dockerapi.APIClass()
            _create_image(instance, PROJECT_NAME)

            while _CONTAINERS_MAX <= _CURRENT_CONTAINERS:
                print(f"Current container pool is full, waiting for " + \
                                                        f"{_WAIT_TIME} sec...")
                sleep(_WAIT_TIME)

            _CURRENT_CONTAINERS += 1
            container = instance.create_container(f"{PROJECT_NAME}-runner",
                memory_limit, network_name=f"{PROJECT_NAME.lower()}_internal")

            dockerapi.APIClass.start_container(container)

            print(f"Started the container {container.name} with id " + \
                                                       f"{container.short_id}")
            ip = instance.resolve_ip(
                cast(str, container.name), f"{PROJECT_NAME.lower()}_internal")
            print(f"IP address for container {container.name} is {ip}")

            output = None
            for _ in range(retries):
                try:
                    output = container_interactor(*args, **kwargs, ip=ip)
                    break
                except ConnectionRefusedError as e:
                    print(e)
                    sleep(_WAIT_TIME)
            else:
                print("Failed to establish connection with container and " + \
                        "get the output of the interactor")

            dockerapi.APIClass.stop_container(container)
            dockerapi.APIClass.remove_container(container)
            _CURRENT_CONTAINERS -= 1
            print(f"Stopped and removed the running container {container.name}")

            return output

        return wrapper

    if _func is not None:
        return decorator_container(_func)
    else:
        return decorator_container
