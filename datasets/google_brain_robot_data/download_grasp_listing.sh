#!/bin/bash

# Example:
#
#   download_listing.sh listing.txt ./tmp
#
# will download all of the files listed in the file, listing.txt, into
# a directory, "./tmp".
#
# Each line of the listing.txt file should contain the path from the
# bucket root to a file.
#
# Source: https://sites.google.com/site/brainrobotdata/home/grasping-dataset

ARGC="$#"
LISTING_FILE=grasp_listing.txt
if [ "${ARGC}" -ge 1 ]; then
  LISTING_FILE=$1
fi
# will actually go to $HOME/datasets/google_brain_robot_data/grasping/*
OUTPUT_DIR="$HOME/datasets/google_brain_robot_data/"
if [ "${ARGC}" -ge 2 ]; then
  OUTPUT_DIR=$2
fi

echo "OUTPUT_DIR=$OUTPUT_DIR"

mkdir -p "${OUTPUT_DIR}"

function download_file {
  FILE=$1
  BUCKET="https://storage.googleapis.com/brain-robotics-data"
  URL="${BUCKET}/${FILE}"
  OUTPUT_FILE="${OUTPUT_DIR}/${FILE}"
  DIRECTORY=`dirname ${OUTPUT_FILE}`
  echo DIRECTORY=$DIRECTORY
  mkdir -p "${DIRECTORY}"
  curl --output ${OUTPUT_FILE} ${URL}
}

while read filename; do
  download_file $filename
done <${LISTING_FILE}
