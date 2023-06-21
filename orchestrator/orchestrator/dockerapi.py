from tarfile import open as taropen
from os import chdir, getcwd, remove

from docker import DockerClient, from_env
from docker.models.containers import Container, Image

from typing import Any, Iterator, Tuple, cast


class APIClass:
    """Class provides the most primitive API, allowing only building images
    from the given context and start them as containers."""

    client: DockerClient
    image: Image
    container: Container

    def __init__(self) -> None:
        self.client = from_env()

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
                    ) -> None:
        """Builds docker image with given context path

        Keyword arguments:
        image_tag -- tag to add to final image
        context_path -- path to context which contains Dockerfile
        dockerfile_path -- path to Dockerfile within the given context
        nocache -- if set True, build without cache
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

        self.image = cast(Tuple[Image, Iterator[Any]],
                     self.client.images.build(**params))[0]

        remove(tarfile_name)
        chdir(previous_dir)

    def create_container(self,
                        image_name: str,
                        memory_limit: int,
                        command: str = '',
                        network: str = ''
                        ) -> Container:
        """Create docker container from given image.

        Keywork arguments:
        image_name -- name of image to base the container on
        memory_limit -- soft memory limit for the container
        command -- overwrite default COMMAND for docker image
        network -- network to attach the container
        """
        params = {
            "image": image_name,
            "command": command,
            "network": network,
            "mem_reservation": f"{memory_limit}m"
        }


        self.container = cast(Container,
                              self.client.containers.create(**params))
        return self.container


    def start_container(self) -> None:
        """Start the container"""
        self.container.start()
