FROM debian:buster

# Add judge system user
RUN useradd -r judge

# Install required packages and remove apt cache when done.
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  file \
  g++ \
  g++-7 \
  gcc \
  ghc \
  libseccomp-dev \
  openjdk-11-jdk-headless openjdk-11-jre-headless ca-certificates-java \
  python \
  python2.7-dev \
  python3 python3-dev python3-pip python3-setuptools \
  wget \
&& apt-get clean && rm -rf /var/bin/apt/lists/*

# Bootstrap pip and setuptools
RUN pip3 install -U pip setuptools

# Install app requirements before rest of code to be cache friendly
COPY judge/requirements.txt /judge/
RUN pip3 install --no-cache-dir -r /judge/requirements.txt

COPY judge /judge
WORKDIR /judge

RUN mkdir /problems

RUN env DMOJ_REDIST=1 python3 setup.py develop && rm -rf build/

COPY judge.yml /judge/

# Install utility so we can easily use docker secrets in docker-entry
RUN pip3 install --no-cache-dir get-docker-secret

COPY docker-entry /judge/docker-entry

USER judge

ENTRYPOINT ["/judge/docker-entry"]