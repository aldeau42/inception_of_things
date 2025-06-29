#!/bin/sh

apk update
apk upgrade
apk add curl

# Wait for token from server
while [ ! -f /vagrant_shared/node-token ]; do
  echo "Waiting for node-token..."
  sleep 5
done

# Join the cluster as a worker node
K3S_TOKEN=$(cat /vagrant_shared/node-token)
curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" \
  INSTALL_K3S_EXEC="--flannel-iface eth1" \
  K3S_URL="https://192.168.56.110:6443" \
  K3S_TOKEN="$K3S_TOKEN" sh -

