#!/bin/bash

is_package_installed() {
  local package_name="$1"
  
  if dpkg -l | grep -q "^ii.*$package_name"; then
    echo "$package_name is installed."
    return 0  # Return success status
  else
    echo "$package_name is not installed."
    return 1  # Return failure status
  fi
}


TRT_LLM_BACKEND_VERSION="r23.12" # they store them as separate branches in git with names like "r24.01"
TRT_LLM_FOLDER="tmp/tensorrtllm_backend"

# clone the desired repo version

if [ -d $TRT_LLM_FOLDER ]; then
    echo "$TRT_LLM_FOLDER folder already exists, exiting"
    
    # ask for confirmation to delete the folder
    read -p "Delete $TRT_LLM_FOLDER folder? (y/n) " -n 1 -r
    echo # move to a new line

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "Deleting $TRT_LLM_FOLDER folder"
        rm -rf $TRT_LLM_FOLDER
    else
        echo "Exiting"
        exit 1
    fi
fi

cd tmp

git clone https://github.com/triton-inference-server/tensorrtllm_backend.git -b $TRT_LLM_BACKEND_VERSION

# build the trt_llm_backend

TRT_LLM_DOCKER_IMAGE_NAME="triton_trt_llm_$TRT_LLM_BACKEND_VERSION"

# sanitize the name by replacing . with _
TRT_LLM_DOCKER_IMAGE_NAME=${TRT_LLM_DOCKER_IMAGE_NAME//./_}

# check if all required packages are installed
package_list=("docker" "docker-buildx" "git-lfs")

# Loop through the list and call the function for each package
for package in "${package_list[@]}"; do
  if is_package_installed "$package"; then
    echo "$package is installed..."
    # Add your script logic here for each package
  else
    echo "Please install $package before running this script."
  fi
done

# Update the submodules
cd tensorrtllm_backend
git lfs install
git submodule update --init --recursive

# check if the docker image is already built
if docker inspect "$image_name:$tag" &> /dev/null; then
  # ask the user if they want to rebuild the image
  read -p "The docker image $TRT_LLM_DOCKER_IMAGE_NAME already exists. Do you want to rebuild it? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting the existing docker image..."
    docker image rm $TRT_LLM_DOCKER_IMAGE_NAME:latest
  else
    echo "Exiting..."
    exit 0
  fi
fi

# Use the Dockerfile to build the backend in a container
# For x86_64
DOCKER_BUILDKIT=1 docker build -t $TRT_LLM_DOCKER_IMAGE_NAME -f dockerfile/Dockerfile.trt_llm_backend .
