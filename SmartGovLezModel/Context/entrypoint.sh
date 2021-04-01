#!/bin/bash

# display script usage
function print_usage() {
  echo "Usage: $0  properties_file [number_of_steps]"  
}

# If user requested usage info
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
  print_usage
  exit 1
fi

if [ $# -lt 1 ]
then
  echo "Providing a properties_file is mandatory."
  print_usage
  exit 1
fi

if [ $# -gt 2 ]
then
  echo "More than two arguments were provided. Exiting."
  print_usage
  exit 1
fi

# FIXME: all the input files (properties_file) are supposed to be
# in the container and there is no way to provide one from the calling
# context...
cd $HOME/SmartGovLezModel/input

# For some (strange/undocummented) reason the properties filename must
# be prefixed with the local directory (i.e. start with "./") or smartgov
# fails to find the file and exits with the esoteric message
#       Exception in thread "main" java.lang.NullPointerException 
if [[ ! $1 == "./"* ]]
then
  properties_file="./"$1
else
  properties_file=$1
fi

# Assert the properties_file exists
if [ ! -f "$properties_file" ]
then
  echo "Properties_file" $1 "does not exist. Exiting."
  exit 1
fi

#### Initialize the properties_file
LEZMODEL="java -Xmx6g -jar $HOME/SmartGovLezModel/SmartGovLez-MASTER.jar"
INITIALIZATION=$LEZMODEL" init -c "$properties_file
echo "Initializing file" $properties_file
echo "  Initialization command" $INITIALIZATION
$INITIALIZATION
echo "Initialization done"
echo ""

#### Running the simulation
COMMAND=$LEZMODEL" run -c "$properties_file
if [ $# -ge 2 ]
then
  # A number of steps argument was provide
  COMMAND+=" -t "$2
fi

echo "Launching simulation"
echo "   simulation command:" $COMMAND
$COMMAND
echo "Simulation done"
echo ""

ls $HOME/SmartGovLezModel/output
