#!/bin/bash

TRT_LLM_BACKEND_VERSION="r23.12" # they store them as separate branches in git with names like "r24.01"

TRT_LLM_DOCKER_IMAGE_NAME="triton_trt_llm_$TRT_LLM_BACKEND_VERSION"
# sanitize the name by replacing . with _
TRT_LLM_DOCKER_IMAGE_NAME=${TRT_LLM_DOCKER_IMAGE_NAME//./_}

CONTAINER_ID=$(docker run -d -it --gpus '"device=0"' --net host --shm-size=2g --ulimit memlock=-1 --ulimit stack=67108864 \
    -v ./models/ensembles/triton_model_unakin:/triton_model_unakin \
    -v ./models/tokenizer:/tokenizer \
    $TRT_LLM_DOCKER_IMAGE_NAME)

echo "Container started: $CONTAINER_ID"
echo "Launching Triton server..."

# Run the server inside the already-running container so it stays alive
docker exec -d "$CONTAINER_ID" python3 scripts/launch_triton_server.py --world_size=1 --model_repo=/triton_model_unakin

echo "Triton server launched. Test with:"
echo "  docker exec -it $CONTAINER_ID python3 /app/inflight_batcher_llm/client/inflight_batcher_llm_client.py --streaming --tokenizer-type llama --tokenizer-dir /tokenizer"
