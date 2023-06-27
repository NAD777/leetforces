from tarfile import open as taropen
from os import chdir, getcwd, remove

from docker import DockerClient, from_env
from docker.client import APIClient
from docker.models.containers import Container, Image
from docker.models.networks import Network

from typing import Any, Iterator, Dict, Tuple, cast


class APIClass:
    """Class provides the most primitive API, allowing only building images
    from the given context and start them as containers."""

    client: DockerClient
    api_client: APIClient


    def __init__(self) -> None:
        self.client = from_env()
        self.api_client = APIClient()

    def __make_tarfile(self, output_filename: str, source_dir: str) -> None:
        """Creates tar archive of given directory

        Keyword arguments:
        output_filenam -- name of the output archive
        source_dir -- directory to pack into the .tar archive
        """
        with taropen(output_filename, "w") as tar:
            tar.add(source_dir)



    def build_image(self,
                    image_tag: str,
                    context_path: str,
                    dockerfile_path: str,
                    nocache: bool = True
                    ) -> Image:
        """Builds docker image with given context path

        Keyword arguments:
        image_tag -- tag to add to final image
        context_path -- path to context which contains Dockerfile
        dockerfile_path -- path to Dockerfile within the given context
        nocache -- if set True, build without cache

        Returns:
        Image object
        """

        previous_dir = getcwd()
        chdir(context_path)

        tarfile_name = "context.tar"
        self.__make_tarfile(tarfile_name, "./")
        params = {
            "fileobj": open(tarfile_name, "rb"),
            "path": ".",
            "dockerfile": dockerfile_path,
            "custom_context": True,
            "tag": image_tag,
            "nocache": nocache,
        }

        image = cast(Tuple[Image, Iterator[Any]],
                     self.client.images.build(**params))[0]

        remove(tarfile_name)
        chdir(previous_dir)

        return image


    def pull_image(self,
                   repository: str,
                   tag: str = ''
                   ) -> Image:
        """Pull the image with given name and return it

        Keyword arguments:
        repository -- repository to pull image from
        tag -- tag of image to pull

        Returns:
        Image object"""

        image = cast(Image, self.client.images.pull(repository, tag))
        return image


    def create_container(self,
                        image_name: str,
                        memory_limit: str,
                        command: str = '',
                        network_name: str = '',
                        ) -> Container:
        """Create docker container from given image.

        Keywork arguments:
        image_name -- name of image to base the container on
        memory_limit -- soft memory limit for the container, string with a
            units identification char (100000b, 1000k, 128m, 1g). If a string
            is specified without a units character, bytes are assumed as an
            intended unit.
        command -- overwrite default COMMAND for docker image
        network_name -- network to attach the container

        Returns:
        Container object"""

        params = {
            "image": image_name,
            "command": command,
            "network": network_name,
            "mem_limit": memory_limit,
        }


        self.container = cast(Container,
                              self.client.containers.create(**params))
        net = cast(Network, self.client.networks.list(names=[network_name])[0])
        net.connect(self.container)
        return self.container


    def resolve_ip(self, container_name: str, network_name: str) -> str:
        """Resolve the ip addres of the given container in the network.

        Keyword arguments:
        container_name -- name of the container to be inspected
        network_name -- name of the network to which the container is attached.
        It is assumed that container is indeed attached to the network.

        Returns:
        ip addres of the container in the given network, if the container is
        present in the network, empty string otherwise"""
        try:
            ip = self.api_client.inspect_container(container_name) \
                    ["NetworkSettings"]["Networks"][network_name]["IPAddress"]
            return ip
        except KeyError as e:
            print(e)
            return ''


    @staticmethod
    def start_container(container: Container, /) -> None:
        """Start the container

        Keyword arguments:
        container -- instance of Container class to start"""

        container.start()


    @staticmethod
    def stop_container(container: Container, /) -> None:
        """Stop the running container

        Keyword arguments:
        container -- instance of Container class to start"""

        container.stop()

    @staticmethod
    def remove_container(container: Container, /) -> None:
        """Remove the given container

        Keyword arguments:
        container: -- instance of Container class to remove"""
        container.remove()


def interact_with_container(self,
                            memory_limit: int,
                            timeout: float
                            ) -> Dict[int, Tuple[str, str]]:
    def wrapper():
        instance = dockerapi.APIClass()
        self.runner_docker_image = self.__create_image(instance)

        # used for default amount of memory
        memory_magic_number = 50
        memory_limit = 1024 * 1024 * (memory_limit + memory_magic_number)
        container = instance.create_container(f"{REPO_NAME_}-runner",
                memory_limit, "", f"{REPO_NAME}_internal", True)

        dockerapi.APIClass.start_container(container)

        print(f"Started the container {container.name} with id" + \
                                                       f"{container.short_id}")
        ip = instance.resolve_ip(
                cast(str, container.name), f"{REPO_NAME}_internal")
        print(f"IP address for container {container.name} is {ip}")

        print(f'uri is: http://{ip}:31337')
        node = ServerProxy(f'http://{ip}:31337')


        # tight loop waiting while the container starts
        loops = 0
        sleep_timeout = 0.5
        output = {}
        while True:
            try:
                sleep(sleep_timeout)
                output :Dict[int, Tuple[str, str]] \
                    = node.generate_test_data(self.gen_details) #type: ignore

                print(node.system.listMethods())
                print(self.gen_details)

            except ConnectionRefusedError as e:
                print(e)
                loops += 1

            finally:
                if loops * sleep_timeout > timeout:
                    break

        APIClass.stop_container(container)
        APIClass.remove_container(container)
        print(f"Stopped and removed the running container {container.name}")

        return output
    return wrapper
