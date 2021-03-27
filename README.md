# Docker-based GNU Radio Development Environment

This repository contains a quick and easy setup for GNU Radio development on a
reproducible Docker-based environment.

> **Note:** The setup was tested on macOS Big Sur with Docker Desktop (M1 build)
> v3.3.0.

First of all, clone GR on the root directory of this project:

```
git clone https://github.com/gnuradio/gnuradio.git
```

Next, prepare to run GUI applications inside the container (e.g., to run
`gnuradio-companion`). Note there will be no X Server running in the
container. Hence, the container will need to use the host's X Server.

For example, on macOS, you can use the XQuartz application on the host to
display GUI applications running inside the container. It is only necessary to
define the `DISPLAY` env var on the running container such that it points to the
host's X server. This is done automatically by the docker-compose recipe (see
`docker-compose.yml`), as long the `HOSTNAME` variable is defined before
launching the container, as follows:

```
export HOSTNAME=`hostname`
```

Next, build and launch the container in detached mode:

```
docker-compose up --build -d
```

Note the compose stack has three volumes:

1. `gr_prefix`: a named volume where GR will be installed.
2. `gr_build`: a named volume containing the GR build directory.
3. A bind mount of the `gnuradio` directory cloned earlier.

The latter (the bind mount volume) allows for editing the GR sources directly
from the host. Any changes made to the `gnuradio/` directory are reflected
inside the container. Likewise, any changes made to the sources inside the
container (e.g., output products from `gr_modtool`) will be visible by the host.

Next, launch an interactive bash session on the running container:

```
docker exec -it gnuradio-docker-env_gnuradio_1 bash
```

Finally, compile GR inside the container:

```
cd src/gnuradio/build/
cmake \
	-DCMAKE_INSTALL_PREFIX=/root/gr_prefix/ \
	-DCMAKE_BUILD_TYPE=Debug \
	-DENABLE_GR_AUDIO=OFF \
	-DENABLE_GR_TRELLIS=OFF \
	-DENABLE_GR_UHD=OFF \
	-DENABLE_GR_VIDEO_SDL=OFF \
	-DENABLE_GR_VOCODER=OFF \
	-DENABLE_GR_WAVELET=OFF \
	-DENABLE_GR_ZEROMQ=OFF \
	../
make
make test
make install
ldconfig
```

Note this command will install GR on the `gr_prefix` named volume mentioned
earlier. Hence, the installation will persist across container
sessions. Likewise, the build directory will be preserved on the `gr_build`
volume. Thus, you can make changes to the sources without needing to re-compile
the whole project tree.

At this point, you should be ready to run and develop with GR. For example, try
launching `gnuradio-companion`:

```
gnuradio-companion
```

> If the application fails to connect to the host's X Server, make sure that:
>
> 1. XQuartz (on macOS) is configured to allow connections from network clients
>    (check `Preferences > Security`).
>
> 2. The container can ping the host via the host's hostname. This works on
>    Docker Mac but may not work in other environments.
>
> 3. Check if you need to authorize the container somehow to access the host's X
>    server (using `xauth` or `xhost`).
