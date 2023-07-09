# iVentoy Container

This is a docker container packaging up the iVentoy tool [https://iventoy.com](https://iventoy.com)

The image is based on Debian 12 Bookworm slim version and uses supervisor to launch the process.

Note: The way iVentoy is written is really weird, there's no daemon or flags (I can find), so just ignore supervisor warnings for now.

## Usage

It uses sysvfs so the container needs to be ran in privileged mode (not ideal!)

### DHCP

By default, I can't find a way of manipulating the configuration at first start.  Unfortunately iVentoy operates it's own DHCP server and will need to be configured to use a external DHCP server in the configuration.

### Ports 

The default web admin endpoint port is 26000 and can be hit using a browser pointing to http://<ip>or<localhost>:26000 in Chrome. 

The default internal iVentoy webserver for serving images is 16000 this is configurable in the admin interface documented here [https://iventoy.com/en/doc_http_url.html](https://iventoy.com/en/doc_http_url.html), if changing ensure you forward the correct port number

TODO: Port 10809 is Linux Network Block Device - I'm not quite sure what iVentoy uses it for, I'm going to assume to mount EFI or ISO's.


```
docker run -d --privileged -p 26000:26000 -p 16000:16000 -p 10809:10809 garybowers/iventoy:1.0.08
```

## Volumes

There are a couple of volumes you can mount, the primary is the `iso` folder, which surprisingly containts your iso images you want to boot.

```
docker run -d --privileged -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/isos:/iventoy/iso garybowers/iventoy:1.0.08
```

There is also the configuration (THIS BIT I HAVE NOT TESTED YET)!
saved in /data so we probably want to mount this to make it save configuration across restarts.

```
docker run -d --privileged -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/isos:/iventoy/iso -v /path/to/data:/iventoy/data garybowers/iventoy:1.0.08
```

