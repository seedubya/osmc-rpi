# osmc-rpi Dockerfile

:bangbang: This is experimental at this time :bangbang:

This repository contains code/processes to build a dockerized [OSMC].


## Set-up

1. Install [Docker](https://www.docker.com/) on your Raspberry pi.
1. Create the directory used to store the kodi configuration files :
    ```shell
        mkdir -p /home/pi/docker_config/osmc-rpi/config
    ```

### Build an Image

1. Clone the repo:
    ```shell
        git clone https://github.com/seedubya/osmc-rpi.git
    ```
1. Change to the repo:
    ```shell
        cd osmc-rpi
    ```
1. Update the OSMC_VERSION in `create_base_image.sh` - you can view the available versions [here]. Select the Raspberry Pi 4 options - hover your mouse over the image, this will show you a version like `20250302` - this is the one you need.
1. Make the builder script executable:
    ```shell
	chmod +x ./create_base_image.sh
    ```
1. Build the base image:
    ```shell
	./create_base_image.sh
    ```
1. Confirm it has created an image to work with. You will likely have seen errors in the previous step...
    ```shell
        docker images
    ```

Assuming you've not seen any errors AND you have a new image ready to use, you can proceed to the next steps.

The _modern_ approach is to use Docker Compose to build and manage your container, I've included the _legacy_ method for completeness, but I'll only be using/testing the compose option.

### Building / Running with Docker Compose

1. Add an entry, similar to that below, to your `docker-compose.yml` file:
  ```shell
  services:
    osmc-rpi:
      container_name: osmc-rpi
      build:
        context: ../osmc-rpi
        dockerfile: Dockerfile
      dns:
        - 192.168.1.10
        - 208.67.222.222
      ports:
        # These ports are in format <host-port>:<container-port>
        - 8081:80 # Public HTTP Port
        #- 443:443 # Public HTTPS Port
        #- 81:81 # Admin Web Port
        # Add any other Stream port you want to expose
        # - '21:21' # FTP
      volumes:
        - /etc/localtime:/etc/localtime:ro
        - /etc/timezone:/etc/timezone:ro
        - /home/pi/docker_config/osmc-rpi/data:/data
        - /home/pi/docker_config/osmc-rpi/config:/config/kodi
        restart: unless-stopped
  ```
1. Start the new container:
  ```shell
  docker compose up -d
  ```
1. Check the logs:
  ```shell
  docker compose logs -f osmc-rpi
  ```

### Legacy Approach

1. Build the new image based on your version :
```
    OSMC_VERSION=20250302
    docker build -t "seedubya/osmc-rpi:${OSMC_VERSION}" --build-arg OSMC_VERSION=${OSMC_VERSION} .
```
1. Start your new OSMC container :
```
    docker run -it --name osmc-rpi --device="/dev/tty1" --device="/dev/fb0" --device="/dev/input" \
      --device="/dev/snd" --device="/dev/vchiq" \
      -v /etc/localtime:/etc/localtime:ro -v /etc/timezone:/etc/timezone:ro \
      -v /home/pi/docker_config/osmc-rpi/config:/config/kodi  -v /home/pi/docker_config/osmc-rpi/data:/data \
      --net=host "seedubya/osmc-rpi:${OSMC_VERSION}"
```

[Docker]: https://www.docker.com/
[OSMC]: https://osmc.tv
[here]: https://osmc.tv/download/
