# iVentoy Container

**tl;dr** – I’ve moved on from this. I’m now trying to build a proper, open-source PXE server in Go that doesn’t do anything shifty behind your back. Check it out:

👉 [**https://github.com/garybowers/bootimus**](https://github.com/garybowers/bootimus)

It’s cross-platform (ARM/AMD64), transparent, and won't mess (too much) with your boot images (you can still audit the code).
Cheers for any feedback!

---

## ⚠️ BEWARE: Security Concerns

This project was originally intended to containerise iVentoy for easier deployment. However, I can no longer recommend using it due to some **properly dodgy security issues** that have come to light.

### The Problem: "Black Box" Injections
The main issue is what’s happening **under the bonnet**. iVentoy is closed-source and has been caught **silently injecting opaque drivers and certificates** into the boot process without disclosure. We’re talking about kernel-level drivers and fake root CAs being shoved into your WinPE/Linux runtime at boot time.

From an infosec perspective, this is a massive red flag. You are essentially allowing a closed-source binary to patch your operating system at a kernel level before the OS is even installed.

### Why this is a risk:
* **Silent Injections:** iVentoy uses udev rule hijacking and device-mapper "tricks" to force ISOs to boot in ways they weren't designed for. While clever, this method involves patching the initramfs of the OS on-the-fly.

* **Silent Certificate Injection:** iVentoy has been caught programmatically installing fake Root CAs into the Windows Registry at boot. This allows for total interception of encrypted traffic.

* **Mystery Binary Blobs:** Significant portions of the code are distributed as pre-compiled blobs. Without reproducible builds, there is no way to verify they haven't been backdoored.

* **Ancient Tooling:** The project relies on software dependencies from 2008 and EOL operating systems, making it a playground for unpatched vulnerabilities.

* **State Compliance:** As a closed-source tool from China, it is subject to laws (like the 2021 RMSV) that require security flaws to be reported to the state 48 hours before the public is notified.


* **Security Bypasses:** It uses questionable techniques (like fake EV certificates) to bypass Windows signature checks. (See: [Issue #106](https://github.com/ventoy/PXE/issues/106) and [Issue #118](https://github.com/ventoy/PXE/issues/118)).

* **Jurisdictional Risk:** Because it is a closed binary operating under jurisdictions with strict National Intelligence Laws (China), there is no way to verify if "state-mandated" backdoors are present. In the world of "Black Hat" infosec, if you can't see the code, you can't trust the boot.

**Use at your own peril.** I’d recommend looking at alternatives (one I'm working on) such as [**Bootimus**](https://github.com/garybowers/bootimus) instead. It’s 100% open-source, written in Go, and aims to provide the same easy drop-in ISO features without the security headaches or the hidden baggage.


### Technical References & Sources
- [Vulnerability Report: Silent Driver/Cert Injection (Issue #106)](https://github.com/ventoy/PXE/issues/106)
- [Cisco Talos: Analysis of the JemmyLoveJenny Root CA tools used](https://blog.talosintelligence.com/old-certificate-new-signature/)
- [Security Scrutiny: The Binary Blob Controversy](https://biggo.com/news/202508061917_Ventoy_Binary_Blobs_Security_Concerns)
- [Legal Context: China's 2021 Vulnerability Reporting Mandates](https://oit.utk.edu/wp-content/uploads/China-National-Security-Laws.pdf)

---

# Iventoy Container

This is a docker container packaging up the iVentoy tool [https://iventoy.com](https://iventoy.com)

The image is based on Debian 12 Bookworm slim version and uses supervisor to launch the process.

Note: The way iVentoy has been developed is really weird, there's no daemon or flags (I can find), so just ignore supervisor warnings for now.

## Versions

Docker Tag:
* 1.0.20-1 : iVentoy v1.0.20,  Logs symlinked from /iventoy/log/log.txt to syslog
* 1.0.20   : iVentoy v1.0.20
* 1.0.19   : iVentoy v1.0.19

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

Another oddity with iVentoy it looks for a /iventoy/data/iventoy.dat file and if that doesn't exist on boot it will fail to load, this causes a issue wanting to persist the /iventoy/data folder.

1. Run iVentoy without the data volume mapped 
```
docker run -d --privileged -p 69:69 -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/isos:/iventoy/iso --name iventoy-tmp garybowers/iventoy:latest
```

copy the contents of the data folder to your persistent storage

```
sudo docker cp iventoy-tmp:/iventoy/data/iventoy.dat /my/local/storage/iventoy/data/
sudo docker cp iventoy-tmp:/iventoy/data/config.dat /my/local/storage/iventoy/data/   <---[Might not exist, skip if not]
sudo docker cp iventoy-tmp:/iventoy/data/mac.db /my/local/storage/iventoy/data/
```

delete the temporary container

```
docker rm iventoy-tmp --force
```

Run iVentoy with the volume for data mounted.

```
docker run -d --privileged -p 69:69 -p 26000:26000 -p 16000:16000 -p 10809:10809 -v /path/to/isos:/iventoy/iso -v /path/to/data:/iventoy/data --name iventoy garybowers/iventoy:latest
```

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
