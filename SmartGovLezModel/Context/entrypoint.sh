#!/bin/bash

set -e

# Note: it is alas not possible to specify the minimum quantity of memory
# given to a container (but only to limit it) refer e.g. to
# https://forums.docker.com/t/container-minimum-memory-allocation/39020
# We thus run things and hope for the best. When things fail then refer
# to Reamde.md#concerning-memory-footprint section 
#
# Note: then command `cgget -n --values-only --variable memory.limit_in_bytes`
# is an a priori boundary. Yet it could well be that cgget annouces a 2Gb
# limit yet that more memory (e.g. 8Gb) happens to be provided at run time
# (depending on your host hardware and docker deamon configurations). 
NUMBER_OF_REQUIRED_GIGABYTES=6

# display script usage
function print_usage() {
  echo -n 'Usage: docker run --mount type=bind,src="$PWD/output",dst="/Output" '
  echo "properties_filename number_of_steps"
  echo "where number_of_steps is an integer."  
}

# If user requested usage info
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
  print_usage
  exit 1
fi

if [ ! $# -eq 2 ]
then
  echo "Providing exactly two arguments is mandatory. Exiting."
  print_usage
  exit 1
fi

if [ ! -d "/Output" ]
then
  echo "No /Output mounting point was provided (to export results). Exiting."
  print_usage
  exit 1
fi
echo ""

# FIXME: all the input files (properties_file) are supposed to be
# in the container and there is no way to provide one from the calling
# context...
cd $HOME/SmartGovLezModel

# For some (strange/undocummented) reason the properties filename must
# be prefixed with the local directory (i.e. start with "./") or smartgov
# fails to find the file and exits with the esoteric message
#       Exception in thread "main" java.lang.NullPointerException 
properties_file="./input/$1"

# Assert the properties_file exists
if [ ! -f "$properties_file" ]
then
  echo "Properties file" $properties_file "does not exist. Exiting."
  exit 1
fi

# Concerning the `-Xmx<size>` flag (memory footprint) the model documentation 
# recommends its usage to avoid JVM crashes due to lack of memory, producing 
# memory errors e.g.
#        "java.lang.OutOfMemoryError: GC overhead limit exceeded"
# Also refer the comments of the above definition of the variable
# NUMBER_OF_REQUIRED_GIGABYTES.
LEZMODEL="java -Xmx"$NUMBER_OF_REQUIRED_GIGABYTES"g "
LEZMODEL+="-jar $HOME/SmartGovLezModel/SmartGovLez-MASTER.jar"

#### Initialize the properties_file
CMD_INITIALIZE=$LEZMODEL" init -c "$properties_file

echo "Initializing file" $properties_file
echo "  Initialization command" $CMD_INITIALIZE
$CMD_INITIALIZE
echo "Initialization done"
echo ""

#### Running the simulation
CMD_RUN=$LEZMODEL" run -c "$properties_file
if [ $# -ge 2 ]
then
  # When number of steps argument was provided
  CMD_RUN+=" -t "$2
fi

echo "Launching simulation"
echo "   simulation command:" $CMD_RUN
$CMD_RUN
echo "Simulation done"
echo ""

# Assert the simulation did write an output file for the arcs
arcs_output_file="./output/lez/simulation/arcs_$2.json"

if [ ! -f "$arcs_output_file" ]
then
  echo "Output arcs file" $arcs_output_file "does not exist. Exiting."
  exit 1
fi

#### Exploit the simulation results to compute the pollution tiles
tiles_output_file="./output/lez/tiles_$2.json"
CMD_TILE_COMPUTE=$LEZMODEL" tile -a "$arcs_output_file" "
CMD_TILE_COMPUTE+="-n ./output/lez/init/nodes.json "
CMD_TILE_COMPUTE+="--tile-size 4000 "
CMD_TILE_COMPUTE+="-o "$tiles_output_file

echo "Computing resulting tiles"
echo "   tile computation command:" $CMD_TILE_COMPUTE
$CMD_TILE_COMPUTE
echo "Tiles computation done."

if [ ! -f "$tiles_output_file" ]
then
  echo "Tiles output file" $tiles_output_file "does not exist. Exiting."
  exit 1
fi
echo ""

#### 'Politic Run' step
CMD_PRUN="$LEZMODEL prun -c $properties_file -i 5"
if [ $# -ge 2 ]
then
  # When number of steps argument was provided
  CMD_PRUN+=" -t $2"
fi

echo "Launching 'Politic Run' step"
echo "   command:" $CMD_PRUN
$CMD_PRUN
echo "'Politic Run' done. Output is in 'output_political' folder."
echo ""

#### Exporting (to container running context) results
echo "Exporting output directory from container."
echo ""
cp -r $HOME/SmartGovLezModel/output /Output/
cp -r $HOME/SmartGovLezModel/output_political /Output/

#### Display the resulting files
echo "Resulting files:"
tree -h /Output
echo ""


echo "Exiting on success."
echo ""
