## Building the container

Build the docker image with the command
`docker build [--no-cache] -t smartgov:lez-model Context`

## Running documentation

`docker run --rm -t smartgov:lez-model --help`

that boils down to
`docker run --rm -t smartgov:lez-model <arguments>` 

## Running examples

Collecting the outputs in a local (to the invocation host) directory
```
mkdir output
docker run -t --mount type=bind,src="$PWD/output",dst="/Output" \
           smartgov:lez-model static_config_lez.properties 86400
```

## Debugging

```
mkdir output
docker run -it --mount type=bind,src="$PWD/output",dst="/Output" \
           --entrypoint=/bin/bash  smartgov:lez-model
```
