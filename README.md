# Docker-based GNU Radio Development Environment

This repository contains a quick and easy setup for GNU Radio (GR) development
on a reproducible Docker-based environment. The configuration was tested on
macOS Big Sur with Docker Desktop (M1 build) v3.3.0. However, it can easily be
adapted to other platforms.

The goal in this setup is to separate the roles of the host and the Docker
container. You will edit the GR sources directly from the host on your editor of
choice. Meanwhile, you will use the container environment to compile GR, install
it, and install all software dependencies. Ultimately, this arrangement
preserves the host in a clean state.

To start, clone GR on the root directory of this project:

```
git clone https://github.com/gnuradio/gnuradio.git
```

This clone is meant to be your working directory for GR development.

## GUI Configuration

Next, prepare to run GUI applications inside the container (e.g., to run
`gnuradio-companion`). Note there will be no X Server running in the
container. Hence, the container will need to use the host's X Server.

For example, on macOS, you can use the XQuartz application on the host to
display GUI applications running inside the container. To do so, first, you need
to define the `DISPLAY` env var on the running container such that it points to
the host's X server. You can test whether this works by running a GUI-based
image such as `xeyes`. For example, run the following:

```
docker run -e DISPLAY=host.docker.internal:0 gns3/xeyes
```

At this point, you will likely see `Error: Can't open display`. That's because
you still need to authorize the container to access the host's X server. To do
so, check the source IP address of the X11 packets coming from the
container. Open a terminal window and run:

```
sudo tcpdump -i any port 6000
```

Then, on another window, run the `xeyes` container and observe the packets on
tcpdump. You should see packets coming from an IP address in the same subnet of
the Docker bridge network.

For example, let's say the source IP address is `192.168.64.2`. Then, you can
authorize this IP address to access the X server by running:

```
xhost + 192.168.64.2
```

> Note: `xhost` provides a simple way to grant access to your host's X
> server. However, it is not the safest approach. If you are worried about
> security, you can implement the X server access [using xauth
> instead](http://wiki.ros.org/docker/Tutorials/GUI).

Now, rerun `xeyes`. It should open the GUI successfully.

> If the GUI still fails, make sure that:
>
> 1. XQuartz (on macOS) is configured to allow connections from network clients
>    (at `Preferences > Security`).
>
> 2. The container can ping the host. On Docker Mac, you can test with `ping
>    host.docker.internal`.

## Launching

Next, build and launch the container in detached mode:

```
docker-compose up --build -d
```

> NOTE: change the `DISPLAY` variable on `docker-compose.yml` if you are not
> running on Docker Mac.

This compose stack creates three volumes:

1. `gr_prefix`: a named volume where GR will be installed.
2. `gr_build`: a named volume containing the GR build directory.
3. A bind mount of the `gnuradio` directory cloned earlier.

The latter (the bind mount volume) allows for editing the GR sources directly
from the host. Any changes made to the `gnuradio/` directory are reflected
inside the container. Likewise, any changes made to the sources inside the
container (e.g., output products from `gr_modtool`) are synchronized back to
the host.

In contrast, the first two volumes (the named volumes) are not tied to a host
directory. Instead, they are isolated on purpose. For example, the `gr_build`
volume will hold the GR build directory such that only the container can access
it, while the host does not see the build directory. This approach is meant to
preserve the state of the host's `gnuradio` directory as clean as possible.

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

The given steps will install GR on the `gr_prefix` named volume mentioned
earlier. Hence, the installation will persist across container sessions. That
is, you can stop the container any time and resume later.

Furthermore, the build directory will be preserved on the `gr_build`
volume. Thus, after the first compilation, you can make incremental changes to
the sources without recompiling the whole project tree.

At this point, you should be ready to run and develop with GR. For example, try
launching `gnuradio-companion`:

```
gnuradio-companion
```
