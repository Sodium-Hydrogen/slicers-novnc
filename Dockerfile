#################### easy-novnc-build ####################
FROM golang:1.14-buster AS easy-novnc-build

# Get and install Easy noVNC.
RUN apt update && apt install git
RUN git clone https://github.com/sodium-hydrogen/easy-novnc.git /src
WORKDIR /src
RUN go mod download
RUN go build .
RUN ls -al /src/easy-novnc

#################### base-gui ####################
FROM debian:buster as base-gui

RUN apt-get update -y
RUN mkdir -p /usr/share/desktop-directories

# Get TigerVNC and Supervisor for isolating the container.
RUN apt-get install -y --no-install-recommends openbox tigervnc-standalone-server supervisor gosu

# Get all of the remaining dependencies for the OS, VNC, and Superslicer.
RUN apt-get install -y --no-install-recommends lxterminal nano wget openssh-client rsync ca-certificates xdg-utils htop tar xzip gzip bzip2 zip unzip

RUN apt update && apt install -y --no-install-recommends --allow-unauthenticated \
        lxde gtk2-engines-murrine gnome-themes-standard gtk2-engines-pixbuf gtk2-engines-murrine arc-theme \
        freeglut3 libgtk2.0-dev libwxgtk3.0-gtk3-dev libwx-perl libxmu-dev libgl1-mesa-glx libgl1-mesa-dri  \
        xdg-utils locales locales-all pcmanfm jq curl git firefox-esr

RUN apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install Superslicer
# Many of the commands below were derived and pulled from previous work by dmagyar on GitHub.
# Here's their Dockerfile for reference https://github.com/dmagyar/prusaslicer-vnc-docker/blob/main/Dockerfile.amd64
WORKDIR /slic3r
ADD get_latest_superslicer_release.sh /slic3r
RUN chmod +x /slic3r/get_latest_superslicer_release.sh

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

# It's time! Let's get to work! We use /configs/ as a bindable volume for Superslicers configurations. We use /prints/ to provide a location for STLs and GCODE files.
CMD ["bash", "-c", "chown -R slic3r:slic3r /home/slic3r/ /configs/ /prints/ /dev/stdout && exec gosu slic3r supervisord"]

#################### lateset-release ####################
FROM base-gui as latest-release

RUN latestSlic3r=$(/slic3r/get_latest_superslicer_release.sh url) \
  && slic3rReleaseName=$(/slic3r/get_latest_superslicer_release.sh name) \
  && curl -sSL ${latestSlic3r} > ${slic3rReleaseName} \
  && tar -xzf ${slic3rReleaseName} -C /slic3r/slic3r-dist --strip-components 1 \
  && rm -f /slic3r/${slic3rReleaseName}

RUN rm -f /slic3r/releaseInfo.json
RUN chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/

#################### tagged-release ####################
FROM base-gui as tagged-release

ARG VERSION
RUN latestSlic3r=$(/slic3r/get_latest_superslicer_release.sh url_ver $VERSION) \
  && slic3rReleaseName=$(/slic3r/get_latest_superslicer_release.sh name_ver $VERSION) \
  && curl -sSL ${latestSlic3r} > ${slic3rReleaseName} \
  && tar -xzf ${slic3rReleaseName} -C /slic3r/slic3r-dist --strip-components 1 \
  && rm -f /slic3r/${slic3rReleaseName}

RUN rm -f /slic3r/releaseInfo.json
RUN chown -R slic3r:slic3r /slic3r/ /home/slic3r/ /prints/ /configs/
