# docker-li3ds

[![Docker Automated buil](https://img.shields.io/docker/automated/oslandia/docker-li3ds.svg)]()
[![Docker Pulls](https://img.shields.io/docker/pulls/oslandia/docker-li3ds.svg)]()

Docker container for the LI³DS datastore

This docker image contain all projects involved in the LI³DS project that can be found in the [LI³DS organization](https://github.com/LI3DS/)


## Building the image

    git clone https://github.com/li3ds/docker-li3ds
    cd docker-li3ds
    docker build -t docker-li3ds .

## Using the image


You can start a container like this:

    docker run --rm -p 5003:5000 -e API_KEY=b05765cf-4a36-413b-ae70-e43e0e3c7595 \
           -it docker-li3ds

The API will then be accessible at [http://localhost:5003](http://localhost:5003)

**mm2li** command line can be invoked with:

    docker exec -it docker-li3ds li3ds
