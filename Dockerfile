# Utilizar la imagen base oficial de OpenClaw desde GHCR
FROM ghcr.io/openclaw/openclaw:latest

USER root

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias básicas y para Godot
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    ca-certificates \
    libfontconfig1 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libgl1-mesa-glx \
    libdbus-1-3 \
    libpulse0 \
    libasound2 \
    libxrender1 \
    libxext6 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Instalar SDK de .NET 8
RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    && ./dotnet-install.sh --channel 8.0 \
    && ln -s /root/.dotnet/dotnet /usr/bin/dotnet

# Configurar variables de entorno para .NET
ENV DOTNET_ROOT=/root/.dotnet
ENV PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# Instalar Godot 4.2.2 .NET (Versión estable actual)
ENV GODOT_VERSION=4.2.2
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64.zip \
    && unzip Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64/Godot_v${GODOT_VERSION}-stable_mono_linux.x86_64 /usr/local/bin/godot \
    && mv Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64/GodotSharp /usr/local/bin/GodotSharp \
    && rm -rf Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64*

# Definir el directorio de trabajo (restaurar al de la imagen base)
WORKDIR /app

# El comando de entrada lo define la imagen base de OpenClaw
# Pero nos aseguramos de que el workspace esté disponible
RUN mkdir -p /workspace
