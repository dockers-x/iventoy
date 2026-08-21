# iVentoy Container

This is a docker container packaging up the iVentoy tool [https://iventoy.com](https://iventoy.com)

The image is based on Debian 12 Bookworm slim. iVentoy runs in foreground mode so Docker can supervise it directly and stop it cleanly.

## Versions

Docker Tag:
* latest / 1.0.39: iVentoy v1.0.39

## Usage

It uses sysvfs so the container needs to be ran in privileged mode (not ideal!) and also needs port 69 which is in a privileged range.

### DHCP

By default, I can't find a way of manipulating the configuration at first start.  Unfortunately iVentoy operates it's own DHCP server and will need to be configured to use a external DHCP server in the configuration.

For configuration of various DHCP servers see the [docs/](docs) folder.

### Ports 

The default web admin endpoint port is 26000 and can be hit using a browser pointing to http://<ip>or<localhost>:26000 in Chrome. 

The default internal iVentoy webserver for serving images is 16000 this is configurable in the admin interface documented here [https://iventoy.com/en/doc_http_url.html](https://iventoy.com/en/doc_http_url.html), if changing ensure you forward the correct port number

Port 10809 is Linux Network Block Device - I'm not quite sure what iVentoy uses it for, I'm going to assume to mount EFI or ISO's.

  - 69/69 UDP = TFTP Port
  - 26000/26000 TCP = iVentoy Web GUI Interface
  - 16000/16000 TCP = iVentoy iso & file server
  - 10809/10809 TCP = Block Device

## Volumes

There are a couple of volumes you can mount, the primary is the `iso` folder, which surprisingly containts your iso images you want to boot.

```
docker run -d --privileged -p 69:69 -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/iso:/iventoy/iso garybowers/iventoy:latest
```

### Persisting Configuration

Following the official upgrade rules, the container refreshes the version-specific `iventoy.dat` and `mac.db` files from the image on every start. Only the generated `config.dat` settings and mounted ISO files are carried across releases. You can therefore mount the persistent data directory on the first run:

```
docker run -d --privileged -p 69:69 -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/isos:/iventoy/iso -v /path/to/data:/iventoy/data --name iventoy garybowers/iventoy:latest
```

Automatic PXE startup is disabled by default so the admin service remains available when the recovered Server IP is missing or no longer exists on the host. Configure a valid Server IP in the web UI first. To opt in afterward, set `IVENTOY_AUTO_RUN=1`; other values, including `0`, keep automatic startup disabled.

Alternatively run on host mode to serve PXE to docker host's LAN:

```
docker run -d --privileged --net=host -v /path/to/isos:/iventoy/iso -v /path/to/data:/iventoy/data --name iventoy garybowers/iventoy:latest
```

### Configure your DHCP server
See the [docs](docs/) folder for examples.

### Configure iVentoy

Once your container is up and running go to the IP address of your server on port 26000 e.g. http://10.0.0.1:26000

1. Ensure the Server IP is selected correctly, on my docker setup I have a dedicated network with it's own IP for this service.
![picture of iVentoy configuration 1](docs/assets/scr1.png)

2. On the configuration menu on the left, If you are using a external DHCP server then ensure the `DHCP Server Mode` is set to `External`
![picture of iVentoy configuration 2](docs/assets/scr2.png)

3. Copy a ISO file to your isos folder (locally as set by the volumes above) and goito the `Image Management` menu on the left and hit refresh.
![picture of iVentoy configuration 2](docs/assets/scr3.png)
![picture of iVentoy configuration 2](docs/assets/scr4.png)

4. Start the server by hitting the bit play button on the `Boot Information` menu screen
![picture of iVentoy configuration 1](docs/assets/scr1.png)
![picture of iVentoy configuration 1](docs/assets/scr5.png)

5. Test booting.
![picture of iVentoy configuration 1](docs/assets/scr6.png)
