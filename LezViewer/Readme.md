# Using lez-viewer with Docker

## Building the container

Build the docker image with the command

```bash
docker build [--no-cache] -t smartgov:lez-viewer Context
```

## Using the container

```bash
docker run --rm -d -p 8080:80 -t smartgov:lez-viewer
```

Note: as explained [in this issue](https://github.com/nginxinc/docker-nginx/issues/418) do not worry about logs mentioning `docker-entrypoint.sh` thingies...

## Debugging

```bash
docker run -it smartgov:lez-viewer bash
```
