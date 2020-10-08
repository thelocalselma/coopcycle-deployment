# Using kind

kind (Kubernetes-in-Docker) is a tool for running a test k8s cluster. It is an
alternative to minikube.

## Installing kind

On macOS, run `brew install kind`. For other platforms see the documentation:
https://kind.sigs.k8s.io/docs/user/quick-start/

## Create a cluster and enable ingress-nginx

```
kind create cluster --config configs/development/kind-cluster.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx master/deploy/static/provider/kind/deploy.yaml

# Wait for ingress to start
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```
