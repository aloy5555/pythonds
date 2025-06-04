#!/bin/bash
set -e

# Usage: ./install_and_build_nds_python.sh your_script.py

# Step 1: Install prerequisites
echo "[*] Installing prerequisites: git, wget, devkitPro, devkitARM, libnds, ndstool..."

sudo apt-get update
sudo apt-get install -y git wget

# Install devkitPro Pacman if not present
if ! command -v dkp-pacman &> /dev/null
then
    echo "[*] Installing devkitPro Pacman..."
    wget https://apt.devkitpro.org/install-devkitpro-pacman
    chmod +x install-devkitpro-pacman
    sudo ./install-devkitpro-pacman
fi

# Install devkitARM and tools
sudo dkp-pacman -Sy --noconfirm devkitARM libnds ndstool

# Step 2: Set up environment variables for devkitPro
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=$DEVKITPRO/devkitARM
export PATH=$DEVKITPRO/tools/bin:$DEVKITARM/bin:$PATH

# Step 3: Clone and build MicroPyDS (MicroPython for NDS)
echo "[*] Cloning MicroPyDS..."
if [ ! -d "MicroPyDS" ]; then
    git clone https://github.com/badsector/MicroPyDS.git
fi

cd MicroPyDS
echo "[*] Building MicroPython for NDS..."
make clean
make

if [ ! -f "micropython.nds" ]; then
    echo "Build failed: micropython.nds not found."
    exit 1
fi
cd ..

# Step 4: Prepare project directory
WORKDIR="./build_nds"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR/data"

# Copy MicroPython .nds as base
cp MicroPyDS/micropython.nds "$WORKDIR/base.nds"

# Step 5: Copy user script and build final .nds
USER_SCRIPT="$1"
if [ -z "$USER_SCRIPT" ]; then
    echo "Usage: $0 test.py"
    exit 1
fi

if [ ! -f "$USER_SCRIPT" ]; then
    echo "Python script $USER_SCRIPT not found"
    exit 1
fi

cp "$USER_SCRIPT" "$WORKDIR/data/main.py"

echo "[*] Building final .nds file with ndstool..."
OUTPUT_NDS="output.nds"
ndstool -c "$OUTPUT_NDS" \
    -9 "$WORKDIR/base.nds" \
    -d "$WORKDIR/data"

echo "[*] Build complete! Output: $OUTPUT_NDS"
