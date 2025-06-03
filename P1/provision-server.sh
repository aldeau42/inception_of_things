#!/bin/sh

# Update system
apk update
apk upgrade
apk add curl

# Install K3s in server mode
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --cluster-init --snapshotter=native --write-kubeconfig-mode 644" sh -

# Wait for K3s to be ready
echo "Waiting for K3s to start..."
while [ ! -f /var/lib/rancher/k3s/server/node-token ]; do
  sleep 2
done

# Share the token with the worker node
cat /var/lib/rancher/k3s/server/node-token > /tmp/node-token

# Wait for kubeconfig to be available
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 2
done

# Configure kubectl
mkdir -p $HOME/.kube
cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
chown $USER:$USER $HOME/.kube/config

