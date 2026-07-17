```
# ============================================
# Distrobox + Podman Setup Complete Config
# ============================================

# 1. Install requirements
apt update && apt install podman curl -y

# 2. Install Distrobox
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh

# 3. Create storage directories
mkdir -p /root/work_space/podman_storage

# 4. Add to .bashrc (permanent env)
cat >> ~/.bashrc << 'EOF'

# Podman & Distrobox Storage
export CONTAINER_STORAGE_PATH=/root/work_space/podman_storage
EOF

# 5. Set Podman storage config (permanent)
mkdir -p /etc/containers
cat > /etc/containers/storage.conf << 'EOF'
[storage]
driver = "overlay"
runroot = "/root/work_space/podman_storage/run"
graphroot = "/root/work_space/podman_storage"
EOF

# 6. Reload bashrc
source ~/.bashrc

# 7. Create Distrobox container
distrobox create --name mybox --image alpine:latest

# 8. Enter container
distrobox enter mybox
```

```
# Enter container
distrobox enter mybox

# List containers
distrobox list

# Stop container
distrobox stop mybox

# Delete container
distrobox rm mybox

# Run command without entering
distrobox enter mybox -- apk add nano
```
