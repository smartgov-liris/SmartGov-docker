## Building the container
Build the docker image with the command
`docker build [--no-cache] -t smartgov:lez-model Context`

## Running documentation
`docker run --rm -t smartgov:lez-model --help`
`docker run --rm -t smartgov:lez-model <arguments>` 

## Running examples
```
docker run -t smartgov:lez-model ./static_config_lez.properties 100
```

Collecting the outputs in a local (to the invocation host) directory
```
mkdir output
docker run --mount type=bind,                  \
       src="$PWD/output",                       \
       dst="/home/user1/SmartGovLezModel/output" \
       -t smartgov:lez-model ./static_config_lez.properties 100
```

## Debugging
`docker run -it smartgov:lez-model /bin/bash`
