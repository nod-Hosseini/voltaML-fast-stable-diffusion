FROM nvcr.io/nvidia/tensorrt:22.11-py3

RUN pip install --upgrade pip && pip install --upgrade tensorrt

RUN git clone https://github.com/NVIDIA/TensorRT.git -b release/8.5 --single-branch \
    && cd TensorRT/ \
    && git submodule update --init --recursive

ENV TRT_OSSPATH=/workspace/TensorRT
WORKDIR /workspace/TensorRT

RUN mkdir -p build \
    && cd build \
    && cmake .. -DTRT_OUT_DIR=$PWD/out \
    && cd plugin \
    && make -j$(nproc)

ENV PLUGIN_LIBS="${TRT_OSSPATH}/build/out/libnvinfer_plugin.so"

COPY requirements.txt /workspace/voltaML-fast-stable-diffusion/requirements.txt

WORKDIR /workspace/voltaML-fast-stable-diffusion

RUN pip3 install -r requirements.txt

COPY . /workspace/voltaML-fast-stable-diffusion

ENV CUDA_MODULE_LOADING=LAZY

RUN chmod +x start.sh

ENTRYPOINT ["./start.sh"]
