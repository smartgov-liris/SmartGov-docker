# Simulation run of LezModelUFD

## Building the container

Build the docker image with the command (can take up to 10')

```bash
docker build [--no-cache] -t smartgov:lez-model-ufd Context
```

## Running documentation

Obtaining the container usage documentation

```bash
docker run --rm -t smartgov:lez-model-ufd --help
```

## Running examples

General usage

```bash
docker run --rm -t smartgov:lez-model-ufd <arguments>
```

```bash
docker run -t smartgov:lez-model-ufd ./static_config_lez.properties 100
```

Collecting the outputs in a local (to the invocation host) directory

```bash
mkdir output
docker run --mount type=bind,src="$PWD/output",dst="/Output"     \
       -t smartgov:lez-model-ufd ./static_config_lez.properties 100
```

## Debugging

Debug the build stage

```bash
docker build [--no-cache] --progress=plain -t smartgov:lez-model-ufd Context
```

Working inside the container

```bash
docker run --mount type=bind,src="$PWD/output",dst="/Output" \
           --entrypoint /bin/bash -it smartgov:lez-model-ufd
```

## Concerning memory footprint

If the simulation exits with a "Killed" error message this probably means that the JVM encountered an "Out of Memory" (OOM) situation. As a model developer you should could

- first understand the implications of running Java inside docker by reading e.g. [java inside docker](https://developers.redhat.com/blog/2017/03/14/java-inside-docker/),
- assert this was indeed a OOM situation with a post-mortem inspection by running `docker inspect <container-id> -f '{{json .State.OOMKilled}}'`
- used a `docker stats <container-id>` on next run to keep track of the memory usage (MEM USAGE column) at run time.
