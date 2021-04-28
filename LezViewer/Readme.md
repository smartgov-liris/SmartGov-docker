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

Then open a web-browser on `http://localhost:8080` and upload the data to be displayed/analyzed.
For example:
 - switch to the "Emissions" tab
 - within the Data section (you might need to deploy the section) provide both
   * an establishement (JSON format) file
   * a resulting tileset as computed by your simulation
 - hit the "Load data" button.

As example input data you might wish to use the results of a simulation of the [LezModelUFD as run with Docker](https://github.com/smartgov-liris/SmartGov-docker/blob/master/SmartGovLezModelUFD/Readme.md#running-examples) and refer to the `output` directory entries
  - `output/lez/init/establishments.json` for the "establishment" and
  - `output/lez/tiles_100.json ` for the pollution tileset.  

## Debugging

```bash
docker run -it smartgov:lez-viewer bash
```
