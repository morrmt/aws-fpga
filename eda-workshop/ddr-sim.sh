#!/bin/bash

# Call getopt to validate the provided input.
options=$(/usr/bin/getopt -o f: --long "test,filesystem:" -- "$@")

# Bad args, something went wrong with getopt
if [ $? -ne 0 ];
then
  echo "1: Incorrect options provided"
  exit 1
fi

# A little magic, necessary when using getopt
eval set -- "$options"

while true; do
    case "$1" in

       -f|--filesystem)
          shift # argument to option is $2. shift to $1
          SCRATCH_FS=$1
          [[ ! $SCRATCH_FS =~ efs|fsx|ec2nfs ]] && {
           echo "filesystem must be 'efs', 'fsx', or 'ec2nfs'."
           exit 1
          }
          shift
          ;;
       --)
          shift
          break
          ;;
    esac
done

SCRATCH_DIR=/${SCRATCH_FS}/scratch
FPGA_REPO=aws-fpga-sa-demo


# Source the HDK environment
echo "Sourcing HDK env"
. /etc/profile.d/aws-f1.sh
. /etc/profile.d/default_module.sh
. /etc/profile.d/modules.sh
. /etc/profile.d/which2.sh
. /efs/workspaces/morrmt/${FPGA_REPO}/hdk_setup.sh

# Move to the cl_dram_dma design and run the test_ddr test simulation
echo "cd'ing into scripts dir"
cd $HDK_DIR/cl/examples/cl_dram_dma/verif/scripts
echo "Running make"
make TEST=test_ddr SCRATCH_DIR=$SCRATCH_DIR

