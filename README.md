# Superslicer noVNC Docker Container

This is a fork of [Prusaslicer noVNC](https://github.com/helfrichmichael/prusaslicer-novnc)

## Overview

This is a super basic noVNC build using supervisor to serve Superslicer in your favorite web browser. 

A lot of this was branched off of helfrichmichael's awesome [prusaslicer-novnc-docker](https://github.com/helfrichmichael/prusaslicer-novnc) project, but
I use my mobile device a decent amount of the time so I needed updates to No VNC and a couple other tweaks. 
## How to use

To run this image, you can run the following command: `docker run --detach --volume=superslicer-novnc-data:/configs/ --volume=superslicer-novnc-prints:/prints/ -p 8080:8080 -e SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" 
--name=superslicer-novnc superslicer-novnc`

This will bind `/configs/` in the container to a local volume on my machine named `superslicer-novnc-data`. Additionally it will bind `/prints/` in the container to `superslicer-novnc-prints` locally on my machine, it will bind port `8080` to `8080`, and finally, it will provide an environment variable to keep Prusaslicer happy by providing an `SSL_CERT_FILE`.

## Links

[SuperSlicer](https://example.com)

[Prusaslicer](https://www.prusa3d.com/prusaslicer/)

[Supervisor](http://supervisord.org/)

[GitHub Source](https://github.com/helfrichmichael/prusaslicer-novnc)

[Docker](https://hub.docker.com/r/mikeah/prusaslicer-novnc)
