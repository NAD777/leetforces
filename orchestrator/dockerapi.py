from tarfile import open as taropen
from os import chdir, getcwd, remove

from docker import DockerClient, from_env
from docker.client import APIClient
from docker.errors import ImageNotFound
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


    def get_image(self,
                  image_name: str
                  ) -> Image | None:
        """Try to get the image by its name.

        Keyword arguments:
        image_name -- name of the image

        Returns:
        Image object if it exitsts, None otherwise"""

        try:
            image = cast(Image, self.client.images.get(image_name))
            return image
        except ImageNotFound as e:
            print(e)
            return None

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
