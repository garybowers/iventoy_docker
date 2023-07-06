# iVentoy Container

This is a docker container packaging up the iVentoy tool (https://iventoy.com)[https://iventoy.com]

The image is based on Debian 12 Bookworm slim version and uses supervisor to launch the process.

Note: The way iVentoy is written is really weird, there's no daemon or flags (I can find), so just ignore supervisor warnings for now.

## Usage

It uses sysvfs so the container needs to be ran in privileged mode (not ideal!)

The default port is 26000 and can be hit using a browser pointing to http://<ip>or<localhost>:26000 in Chrome. 


```
docker run -d --privileged -p 26000:26000 garybowers/iventoy:1.0.08
```


## Volumes

There are a couple of volumes you can mount, the primary is the `isos` folder, which surprisingly containts your isos for the images you want to boot.

```
docker run -d --privileged -p 26000:26000 -v /path/to/isos:/iventoy/isos garybowers/iventoy:1.0.08
```


