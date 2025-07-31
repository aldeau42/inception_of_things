# Install k3d and kubectl
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install Argo CD CLI
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Create k3d cluster
k3d cluster create iot-cluster --api-port 6550 -p "8888:80@loadbalancer"

# Create namespaces
kubectl create namespace argocd
kubectl create namespace dev
kubectl create namespace gitlab

# Install Argo CD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD to be ready
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

# Port-forward Argo CD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

# Attendre que l'interface soit dispo
until curl -k https://localhost:8080 > /dev/null 2>&1; do
  sleep 2
done

# Get admin password
echo "Argo CD Admin password:"
echo "\e[32m$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)\e[0m"

# Login to Argo CD CLI
argocd login localhost:8080 --username admin --password $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d) --insecure

# Create Argo CD application
argocd app create playground \
  --repo http://host.k3d.internal:9182/root/aderouin.git \
  --path P3/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

# Enable auto-sync
argocd app set playground \
  --sync-policy automated \
  --auto-prune \
  --self-heal
