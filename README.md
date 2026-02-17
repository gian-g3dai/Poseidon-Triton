# Poseidon-Triton

Automation scripts for building and deploying LLM inference servers using [NVIDIA Triton Inference Server](https://developer.nvidia.com/triton-inference-server) and [TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM).

## Overview

Poseidon-Triton streamlines the end-to-end workflow for serving large language models in production:

1. **Build** a TensorRT-LLM optimized model engine
2. **Containerize** the server environment via Docker
3. **Deploy** the model on a Triton Inference Server

## Repository Structure

```
Poseidon-Triton/
├── Dockerfile.trt_llm         # Docker image for TensorRT-LLM + Triton environment
├── build_model.sh             # Build / compile the TensorRT-LLM model engine
├── build_triton_server.sh     # Build the Triton Inference Server container
├── deploy_model.sh            # Deploy the compiled model to a running Triton server
├── DANGER.txt                 # Important warnings and caveats
├── README.md
├── .gitattributes
└── .gitignore
```

## Getting Started

### Prerequisites

- Docker with NVIDIA Container Toolkit (`nvidia-docker`)
- NVIDIA GPU(s) with sufficient VRAM for your target model
- Model weights (e.g., Code Llama, Llama 2, or other supported architectures)

### Workflow

**1. Build the TensorRT-LLM model engine:**

```bash
./build_model.sh
```

This compiles the model weights into an optimized TensorRT-LLM engine for high-throughput inference.

**2. Build the Triton server container:**

```bash
./build_triton_server.sh
```

Uses `Dockerfile.trt_llm` to create a Docker image with all necessary dependencies.

**3. Deploy the model:**

```bash
./deploy_model.sh
```

Launches the Triton Inference Server and loads the compiled model engine for serving.


## Contributing

Contributions, issues, and feature requests are welcome. Feel free to open an issue or submit a pull request.
