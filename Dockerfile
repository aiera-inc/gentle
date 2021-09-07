FROM nvcr.io/nvidia/kaldi:19.03-py3

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-key adv --refresh-keys --keyserver keyserver.ubuntu.com && \
	apt-get -y install software-properties-common && \
	add-apt-repository ppa:deadsnakes/ppa && \
	apt-get update && \
	apt-get -y install python3.9 python3.9-distutils && \
	apt remove python3.5-minimal -y && \
	ln -sf /usr/bin/python3.9 /usr/bin/python3 && \
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
	python3.9 get-pip.py && \
	rm get-pip.py && \
	apt-get clean

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y \
		gcc g++ gfortran \
		libc++-dev \
		libstdc++6 zlib1g-dev \
		automake autoconf libtool \
		git subversion \
		libatlas3-base \
		#nvidia-cuda-dev \
		ffmpeg \
		python3.9 python3.9-dev \
		python python-dev python-pip \
		wget unzip patch && \
	apt-get clean

ADD ext /gentle/ext
RUN export MAKEFLAGS=' -j8' &&  cd /gentle/ext && \
	./install_kaldi.sh && \
	make depend && make && rm -rf kaldi *.o

ADD . /gentle
RUN cd /gentle && ./install_models.sh
RUN cd /gentle && pip3 install redis twisted && python3 setup.py develop

EXPOSE 8765

VOLUME /gentle/webdata

CMD cd /gentle && python3 serve.py
