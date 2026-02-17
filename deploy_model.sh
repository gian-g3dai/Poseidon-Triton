#!/bin/bash

TRT_LLM_BACKEND_VERSION="r23.12" # they store them as separate branches in git with names like "r24.01"

TRT_LLM_DOCKER_IMAGE_NAME="triton_trt_llm_$TRT_LLM_BACKEND_VERSION"
# sanitize the name by replacing . with _
TRT_LLM_DOCKER_IMAGE_NAME=${TRT_LLM_DOCKER_IMAGE_NAME//./_}

docker run -d -it --gpus '"device=0"' --net host --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
    -v ./models/ensembles/triton_model_unakin:/triton_model_unakin \
    -v ./models/tokenizer:/tokenizer \
    $TRT_LLM_DOCKER_IMAGE_NAME

# TODO find a way to run this in detached mode, we can't run as cmd because the container will exit abruptly:
#
# python3 scripts/launch_triton_server.py --world_size=1 --model_repo=/triton_model_unakin
#
# can test with /app/inflight_batcher_llm/client# python3 inflight_batcher_llm_client.py --streaming --tokenizer-type llama --tokenizer-dir /tokenizer
