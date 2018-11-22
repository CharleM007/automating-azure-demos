
. ../vars.ps1

# Due to some RS AD tenant permissions that we're not setting up here,
# you'll likely need to run this as yourself
az login

$RG_NAME="ms-workshop-aks"
$CLUSTER_NAME="aks-01"

# Create a Resource Group
az group create --name $RG_NAME --location "$defaultLocation"

# Create a cluster
az aks create `
    --resource-group $RG_NAME `
    --name $CLUSTER_NAME `
    --node-count 3 `
    --enable-addons monitoring `
    --generate-ssh-keys

# This will take a while (20m or so). Let's come back in a bit

# Generate credentials
az aks get-credentials --resource-group $RG_NAME --name $CLUSTER_NAME

# View Nodes
kubectl get nodes

# Set up RBAC for the Dashboard
kubectl create clusterrolebinding kubernetes-dashboard `
    --clusterrole=cluster-admin `
    --serviceaccount=kube-system:kubernetes-dashboard

# Open the Dashboard
az aks browse --resource-group $RG_NAME --name $CLUSTER_NAME &

# Deploy an echo server app
kubectl apply -f ./echo-app

# The Load Balancer takes a while to get created...

# Deploy an echo server app
kubectl delete -f ./echo-app

# Setup RBAC for Helm Tiller
kubectl create serviceaccount -n kube-system tiller
kubectl create clusterrolebinding tiller-binding --clusterrole=cluster-admin --serviceaccount kube-system:tiller
helm init --service-account tiller

# Install Consul
helm install --name consul stable/consul
kubectl get pods --namespace=default -w

# Open the Consul UI
kubectl port-forward svc/consul-ui 8500:8500 &
open http://localhost:8500/ui/

# Clean up
helm delete consul
kubectl delete pvc -l release=consul

# Remove our AKS cluster
az aks delete --yes --no-wait `
    --resource-group $RG_NAME `
    --name $CLUSTER_NAME

# Delete the Resource Group
az group delete --no-wait --yes --name $RG_NAME