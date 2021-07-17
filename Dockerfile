FROM ubuntu:focal

# Utilities and libraries
RUN apt update && \
	DEBIAN_FRONTEND="noninteractive" apt install -y \
	clang-format \
	cmake \
	doxygen \
	g++ \
	gdb \
	gir1.2-gtk-3.0 \
	git \
	libboost-all-dev \
	libfftw3-dev \
	libgmp3-dev \
	liblog4cpp5-dev \
	libqwt-qt5-dev \
	pkg-config \
	python3-click-plugins \
	python3-distutils \
	python3-gi-cairo \
	python3-mako \
	python3-numpy \
	python3-pip \
	python3-pyqt5 \
	python3-pyqtgraph \
	python3-scipy \
	python3-yaml \
	qtbase5-dev

RUN apt install -y --no-install-recommends libuhd-dev

# Useful for gr-dvbs2rx development
RUN apt install -y software-properties-common && \
	add-apt-repository -y ppa:blockstream/satellite && \
	apt install -y tsduck

# Python dependencies and tools
RUN pip3 install \
	"pybind11[global]" \
	cmakelang \
	pygccxml

# Volk
RUN mkdir src/ && cd src/ && \
	git clone --recursive https://github.com/gnuradio/volk.git && \
	cd volk && mkdir build && cd build && \
	cmake -DCMAKE_BUILD_TYPE=Release -DPYTHON_EXECUTABLE=/usr/bin/python3 ../ \
	&& make && make test && make install

# Configure the paths required to run GR
ENV GR_PREFIX=/root/gr_prefix
WORKDIR $GR_PREFIX
RUN PYSITEDIR=$(python3 -m site --user-site) && \
	mkdir -p "$PYSITEDIR" && \
	echo "$GR_PREFIX/lib/python3/dist-packages/" > "$PYSITEDIR/gnuradio.pth"
RUN echo "$GR_PREFIX/lib/" >> /etc/ld.so.conf.d/gnuradio.conf
RUN echo "export PATH=$GR_PREFIX/bin/:${PATH}" >> /root/.bashrc

# Change the entrypoint to run ldconfig on startup
ADD entrypoint.sh /bin/entrypoint
ADD install*.sh /etc/util/
RUN chmod +x /bin/entrypoint
ENTRYPOINT ["/bin/entrypoint"]
CMD ["/bin/bash"]
