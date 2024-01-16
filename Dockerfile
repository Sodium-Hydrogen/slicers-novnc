#################### easy-novnc-build ####################
FROM golang:1.20-bookworm AS easy-novnc-build

# Get and install Easy noVNC.
RUN apt update && apt install git
RUN git clone https://github.com/sodium-hydrogen/easy-novnc.git /src
WORKDIR /src
RUN go mod download
RUN go build .
RUN ls -al /src/easy-novnc

#################### base-gui ####################
FROM debian:bookworm as base-gui

RUN apt-get update -y
RUN mkdir -p /usr/share/desktop-directories

# Get TigerVNC and Supervisor for isolating the container.
RUN apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu

# Get all of the remaining dependencies for the OS, VNC, and slicer.
RUN apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip jq curl git

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        xfce4 locales locales-all xdg-utils pcmanfm firefox-esr \
        libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri

RUN apt install -y libwebkit2gtk-4.0-dev

RUN apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install slicer
# Many of the commands below were derived and pulled from previous work by dmagyar on GitHub.
# Here's their Dockerfile for reference https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/Dockerfile.amd64
WORKDIR /slic3r
COPY unpack_executable.sh ./
COPY get_latest_release ./get_latest_release
RUN chmod -R +x /slic3r/get_latest_release/*.sh

RUN groupadd slic3r
RUN useradd -g slic3r --create-home --home-dir /home/slic3r slic3r
RUN mkdir -p /slic3r
RUN mkdir -p /slic3r/slic3r-dist
RUN mkdir -p /configs
RUN mkdir -p /prints/
RUN mkdir -p /configs/.local
RUN mkdir -p /configs/.config/
RUN locale-gen en_US
RUN ln -s /configs/.config/ /home/slic3r/
#RUN mkdir -p /home/slic3r/.config/
  # We can now set the Download directory for Firefox and other browsers.
  # We can also add /prints/ to the file explorer bookmarks for easy access.
RUN echo "XDG_DOWNLOAD_DIR=\"/prints/\"" >> /home/slic3r/.config/user-dirs.dirs
RUN echo "file:///prints prints" >> /home/slic3r/.gtk-bookmarks

COPY --from=easy-novnc-build /src/easy-novnc /usr/local/bin/
COPY menu.xml /etc/xdg/openbox/
COPY supervisord.conf /etc/

EXPOSE 8080

VOLUME /configs/
VOLUME /prints/

LABEL maintainer="Mike Julander <me@mikej.tech>"

ENV SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"

# It's time! Let's get to work! We use /configs/ as a bindable volume for slicers configurations. We use /prints/ to provide a location for STLs and GCODE files.
CMD ["bash", "-c", "chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout && exec gosu slic3r supervisord"]

#################### lateset-release ####################
FROM base-gui as latest-release

ARG SLICER

RUN /bin/bash unpack_executable.sh ${SLICER}
RUN chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/

#################### tagged-release ####################
FROM base-gui as tagged-release

ARG SLICER
ARG VERSION

RUN /bin/bash unpack_executable.sh ${SLICER} ${VERSION}
RUN chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/
