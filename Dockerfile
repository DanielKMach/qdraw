# Use an official Ubuntu as a parent image
FROM ubuntu/nginx:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    python3 \
    python3-pip \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Zig
RUN wget https://ziglang.org/download/0.13.0/zig-linux-x86_64-0.13.0.tar.xz && \
    tar -xf zig-linux-x86_64-0.13.0.tar.xz && \
    mv zig-linux-x86_64-0.13.0 /opt/zig && \
    ln -s /opt/zig/zig /usr/local/bin/zig

# Install Emscripten
RUN wget https://github.com/emscripten-core/emsdk/archive/refs/tags/3.1.53.tar.gz && \
    tar -xf 3.1.53.tar.gz && \
    mv emsdk-3.1.53 /opt/emsdk && \
    cd /opt/emsdk && \
    ./emsdk install latest && \
    ./emsdk activate latest && \
    echo "source /opt/emsdk/emsdk_env.sh" >> ~/.bashrc

# Set up the working directory
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

# Build zig project
RUN zig build -Dtarget=wasm32-emscripten --sysroot /opt/emsdk/upstream/emscripten --release=safe && \
    cp zig-out/htmlout/* /var/www/html