# Orca/Prusa/Super-slicer noVNC Docker Containers

This is a fork of [Prusaslicer noVNC](https://github.com/helfrichmichael/prusaslicer-novnc)

## Overview

This is a super basic noVNC build using supervisor to serve Orca/Prusa/Super slicer in your favorite web browser.

A lot of this was branched off of helfrichmichael's awesome
[prusaslicer-novnc-docker](https://github.com/helfrichmichael/prusaslicer-novnc) project, but
I use my mobile device a decent amount of the time so I needed updates to No VNC and a couple other tweaks.

## How to use

To run this image, you can run the following command:

```bash
SLICER="orcaslicer"
docker run --detach --volume=${SLICER}-novnc-data:/configs/ --volume=${SLICER}-novnc-prints:/prints/ -p 8079:8080 --name=${SLICER}-novnc slicer-novnc:${SLICER}
```
where `SLICER` is either prusaslicer, orcaslicer, or superslicer

This will bind `/configs/` in the container to a local volume on my machine named `orcaslicer-novnc-data`.
Additionally it will bind `/prints/` in the container to `orcaslicer-novnc-prints` locally on my machine,
and it will bind port `8079` to `8080`.

If you need to change the certificate store you can add `-e SSL_CERT_FILE="/etc/ssl/certs/new-store.crt"`
to the docker run command.

## Version

Every update pushes a total of four tags for each slicer to docker hub.

* slicer name with no added dashes
  * This tag will include all releases that are marked as official release from the superslicer github.
* ...-prerelease
  * This is all releases even those marked as pre-release. It may often be the same as latest.
* ...-x.x (version)
  * The latest release including pre-releases that have the bug fix number removed.
* ...-x.x.x.x (version)
  * Any version that is marked as official (non pre-release) with x.x.x.x being their tag
* ...-prerelease-x.x.x.x
  * Any release including pre-releases with x.x.x.x being their tag.

## Mobile Friendly Efforts

The original version doesn't support mobile phones, but that is important for me.

Changes that improve mobile support are:

* Update novnc to add touch gestures to simulate mouse actions
  * Short tap and drag: left mouse click and drag
  * Drag two fingers: send mouse scroll
  * Tap with two fingers: send right click
  * Pinch with two fingers: send Ctrl + scroll
  * Long press then drag: send right mouse click and drag

* Added `scale resolution` to the context menu.
  * While I am working on minimum screen size settings for NOVNC I've added this temporary fix.
  1. Double tap the blue menu bar of superslicer to shrink the window.
  2. In the black desktop that appears use a single tap with two fingers to bring up the context menu.
  3. Using only one finger select `scale resolution`.
  4. Then opening the novnc settings you can turn on the `Move/Drag Viewport` setting.
      * Both right and left mouse click and drag are disabled with viewport drag enabled.

## Links

[SuperSlicer](https://github.com/supermerill/SuperSlicer)

[GitHub Source](https://github.com/Sodium-Hydrogen/superslicer-novnc)

[Docker Hub](https://hub.docker.com/r/sodiumhydrogen/superslicer-novnc)
