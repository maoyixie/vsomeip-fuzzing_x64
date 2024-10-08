# Use the latest AFL++ image as the base
FROM aflplusplus/aflplusplus:latest

# Set environment variables
ENV TERM=xterm-256color

# Set working directory
WORKDIR /

# Install necessary packages
RUN apt update && \
    apt install -y cmake protobuf-compiler gcc-11 g++-11 g++ build-essential \
    libboost-system-dev libboost-thread-dev libboost-program-options-dev \
    libboost-test-dev libboost-all-dev

# Build AFL++ with QEMU mode
WORKDIR /AFLplusplus
RUN cd qemu_mode && \
    NO_CHECKOUT=1 CPU_TARGET=x86_64 STATIC=1 ./build_qemu_support.sh

# Clone and build vSomeIP
WORKDIR /
RUN git clone https://github.com/COVESA/vsomeip && \
    cd vsomeip && \
    git checkout 637fb6ccce969f89621660dd481badb29a90d661 && \
    cmake -Bbuild -DCMAKE_INSTALL_PREFIX=../install_folder -DENABLE_SIGNAL_HANDLING=1 . && \
    cmake --build build --target install -- -j64

# Setup fuzzing project
WORKDIR /
RUN mkdir vsomeip-fuzzing && \
    cd vsomeip-fuzzing && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_x64/main/src/fuzzing.cpp && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_x64/main/src/fuzzing.hpp && \
    wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_x64/main/CMakeLists.txt && \
    mkdir build && \
    cd build && \
    cmake -D USE_GCC=ON /vsomeip-fuzzing && \
    make -j4

# Prepare fuzzing directory and copy executable
WORKDIR /
RUN mkdir fuzzing && \
    cd fuzzing && \
    mkdir input output && \
    cp /vsomeip-fuzzing/build/fuzzing /fuzzing/

# Download initial test case
WORKDIR /fuzzing/input
RUN wget https://raw.githubusercontent.com/maoyixie/vsomeip-fuzzing_x64/main/input/vsomeip.json

# Set default work directory
WORKDIR /fuzzing
