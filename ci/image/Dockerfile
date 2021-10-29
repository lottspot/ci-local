FROM ubuntu:20.04
ADD prepare-os-ubuntu.sh /bootstrap.sh
RUN  /bootstrap.sh && rm -rf /var/lib/apt/lists/* /bootstrap.sh
ENTRYPOINT [ "/entrypoint.sh" ]
WORKDIR /home
ADD entrypoint.sh /entrypoint.sh
