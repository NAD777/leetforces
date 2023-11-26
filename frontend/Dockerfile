FROM ubuntu:22.04
RUN apt update
RUN apt install -y wget xz-utils git
RUN mkdir /app
WORKDIR /app
RUN wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz
RUN tar xf flutter_linux_3.10.6-stable.tar.xz
RUN rm flutter_linux_3.10.6-stable.tar.xz
ENV PATH="${PATH}:/app/flutter/bin"
COPY . /app
RUN git config --global --add safe.directory /app/flutter
RUN dart pub get
RUN flutter build web --release
ENTRYPOINT ["flutter", "run", "--release", "--web-renderer", "html", "-d", "web-server", "--web-port=8080", "--web-hostname", "0.0.0.0"]
