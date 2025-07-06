#!/bin/bash

# Install k3d
echo "🔧 Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Install kubectl
echo "🔧 Installing kubectl..."
curl -LO "https://dl.k8s.io/release/v1.30.1/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Install helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Argo CD CLI
echo "🔧 Installing Argo CD CLI..."
curl -sSL -o argocd "https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64"
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Create k3d cluster
echo "🚀 Creating k3d cluster..."
k3d cluster create iot-cluster --api-port 6550 -p "8888:80@loadbalancer"

# Add /etc/hosts entry for local GitLab
echo "🔧 Adding local.gitlab to /etc/hosts..."
if ! grep -q "local.gitlab" /etc/hosts; then
    echo "127.0.0.1 local.gitlab" | sudo tee -a /etc/hosts
fi

# Add Helm repo
echo "📦 Adding GitLab Helm repo..."
helm repo add gitlab https://charts.gitlab.io/
helm repo update

# Create namespaces
echo "📁 Creating namespaces..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace dev --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace gitlab --dry-run=client -o yaml | kubectl apply -f -

# Install GitLab with custom values
echo "📦 Installing GitLab via Helm..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --set global.hosts.domain=local.gitlab \
  --set certmanager.install=false \
  --set nginx-ingress.enabled=true \
  --set prometheus.install=false \
  --set global.edition=ce \
  -f gitlab/values.yaml

# Wait for GitLab webservice to be ready
echo "⏳ Waiting for GitLab to be ready (this may take a few minutes)..."
kubectl rollout status deployment/gitlab-webservice-default -n gitlab --timeout=600s

kubectl get pods -n gitlab
kubectl get svc -n gitlab

# Install Argo CD
echo "📦 Installing Argo CD..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for Argo CD server to be ready
echo "⏳ Waiting for Argo CD server to be ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

# Port-forward Argo CD UI
echo "🔌 Port-forwarding Argo CD to localhost:8080..."
kubectl port-forward svc/argocd-server -n argocd 8080:80 &

# Wait for port-forward to be live
sleep 5

# Get Argo CD admin password
echo "🔐 Argo CD Admin password:"
echo "\e[32m$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d)\e[0m"

# Login to Argo CD CLI
echo "🔐 Logging in to Argo CD CLI..."
argocd login localhost:8080 \
  --username admin \
  --password $(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d) \
  --insecure

# Create Argo CD application
echo "🚀 Creating Argo CD application 'playground'..."
argocd app create playground \
  --repo https://github.com/aldeau42/inception_of_things \
  --path P3/app \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

# Enable auto-sync
argocd app set playground \
  --sync-policy automated \
  --auto-prune \
  --self-heal

echo "✅ Setup complete! GitLab is available at http://local.gitlab"
echo "✅ Argo CD UI available at http://localhost:8080"

