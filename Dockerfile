FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless \
        apktool \
        zipalign \
        apksigner \
        xmlstarlet \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY patch-apk.sh /usr/local/bin/patch-apk.sh
RUN chmod +x /usr/local/bin/patch-apk.sh

ENTRYPOINT ["patch-apk.sh"]
CMD ["--help"]
