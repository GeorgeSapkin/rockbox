FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y\
        --force-yes\
        --no-install-recommends\
        -o Dpkg::Options::='--force-confnew'\
        autoconf\
        automake\
        bison\
        build-essential\
        bzip2\
        ca-certificates\
        curl\
        flex\
        gcc\
        git\
        gzip\
        libtool-bin\
        make\
        patch\
        python\
        sqlite\
        texinfo\
        zip

COPY rockboxdev.sh /
# splitting into separate commands to cache individual results
RUN /bin/bash -c "/rockboxdev.sh <<< 'a'"
RUN /bin/bash -c "/rockboxdev.sh <<< 'i'"
RUN /bin/bash -c "/rockboxdev.sh <<< 'm'"
RUN /bin/bash -c "/rockboxdev.sh <<< 's'"
