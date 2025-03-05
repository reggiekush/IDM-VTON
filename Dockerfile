FROM nvidia/cuda:12.5.1-devel-ubuntu24.04

# Update, install needed packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common \
        git-lfs \
        libgl1 \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository -y ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
      build-essential \
      python3.11 \
      python3.11-dev \
      python3.11-venv \
      python3.11-distutils

RUN git lfs install

# Clone IDM-VTON
RUN git clone https://github.com/FurkanGozukara/IDM-VTON /workspace/IDM-VTON
WORKDIR /workspace/IDM-VTON

# Create virtual environment
RUN python3.11 -m venv /workspace/IDM-VTON/venv

# Upgrade pip in venv
RUN /workspace/IDM-VTON/venv/bin/pip install --upgrade pip

# Install requests and tqdm
RUN /workspace/IDM-VTON/venv/bin/pip install --no-cache-dir requests tqdm

# Install packages from requirements
RUN /workspace/IDM-VTON/venv/bin/pip install --no-cache-dir -r requirements.txt

# Install PyTorch, etc.
RUN /workspace/IDM-VTON/venv/bin/pip install --no-cache-dir \
    torch==2.2.0 \
    torchvision \
    torchaudio \
    --index-url https://download.pytorch.org/whl/cu121 --upgrade

# Install xformers, bitsandbytes, accelerate, peft, etc.
RUN /workspace/IDM-VTON/venv/bin/pip install --no-cache-dir \
    xformers==0.0.24 \
    bitsandbytes==0.43.0 \
    accelerate==0.30.1 \
    peft==0.11.1 --upgrade

# Install gradio, huggingface_hub, hf_transfer
RUN /workspace/IDM-VTON/venv/bin/pip install --no-cache-dir \
    gradio \
    huggingface_hub \
    hf_transfer

ENV PYTHONWARNINGS=ignore
ENV HF_HUB_ENABLE_HF_TRANSFER=1

EXPOSE 7812

# Use absolute paths at runtime as well
CMD ["/bin/bash", "-c", "/workspace/IDM-VTON/venv/bin/python app_VTON.py"]
