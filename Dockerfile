FROM nvcr.io/nvidia/kaldi:20.11-py3

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y \
		gcc g++ gfortran \
		libc++-dev \
		libstdc++-6-dev zlib1g-dev \
		automake autoconf libtool \
		git subversion \
		libatlas3-base \
		nvidia-cuda-dev \
		ffmpeg \
		python3 python3-dev python3-pip \
		python python-dev python-pip \
		wget unzip && \
	apt-get clean

ADD ext /gentle/ext
RUN export MAKEFLAGS=' -j8' && cd /gentle/ext && \
	./install_kaldi.sh && \
	make depend && make && rm -rf kaldi *.o

ADD install_models.sh /gentle/install_models.sh
ADD setup.py /gentle/setup.py
RUN cd /gentle && ./install_models.sh
ADD . /gentle
RUN cd /gentle && python3 setup.py develop

EXPOSE 8765

VOLUME /gentle/webdata

CMD cd /gentle && python3 serve.py
