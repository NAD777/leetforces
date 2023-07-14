FROM ubuntu
RUN apt update
RUN apt install -y wget xz-utils git
RUN mkdir /app
WORKDIR /app
RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.10.6-stable.tar.xz
RUN tar xf flutter_linux_3.10.6-stable.tar.xz
ENV PATH="${PATH}:/app/flutter/bin"
RUN dart pub global activate dhttpd
ENV PATH="${PATH}:/root/.pub-cache/bin"
COPY frontend /app
RUN git config --global --add safe.directory /app/flutter
RUN flutter build web --release
WORKDIR /app/build/web
ENTRYPOINT ["/root/.pub-cache/bin/dhttpd", "--host=0.0.0.0"]
