#!/bin/bash

# TODO check if nvidia-container-toolkit is installed
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html

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

if ! is_package_installed "nvidia-container-toolkit"; then
  echo "Please install nvidia-container-toolkit to use gpu accelerated containers!"
fi

# Check if at least two arguments are provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 INPUT_MODEL_DIR"
    exit 1
fi

# Assign command line arguments to variables
INPUT_MODEL_DIR="$1"
OUTPUT_ENGINE_DIR="/models/ensembles/triton_model_unakin/tensorrt_llm/1/"

# build the image
BUILDER_IMG_NAME="trt_llm_builder"
GPUS="device=0" #"all", "device=0", etc.

docker build -t $BUILDER_IMG_NAME -f Dockerfile.trt_llm .

# run the image (create a disposable container to save space, remove --rm if testing things with run.py)
docker run --gpus $GPUS --rm -v ./models:/models $BUILDER_IMG_NAME \
  --meta_ckpt_dir $INPUT_MODEL_DIR \
  --dtype float16 \
  --paged_kv_cache \
  --use_inflight_batching \
  --remove_input_padding \
  --use_gpt_attention_plugin float16 \
  --use_gemm_plugin float16 \
  --enable_context_fmha \
  --output_dir $OUTPUT_ENGINE_DIR \
  --rotary_base 1000000 \
  --vocab_size 32016 \
  --max_batch_size "8" \
  --max_input_len 32256 \
  --max_output_len 16384 \
  --max_num_tokens 16384 \
  --enable_context_fmha
  # --enable_pos_shift

  # somehow increasing max_num_tokens fixed the silent deadlock?
