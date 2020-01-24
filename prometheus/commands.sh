# install the Stackdriver Collector to get those metrics exported to the Stackdriver backend, add env variables
export KUBE_NAMESPACE=prometheus
export KUBE_CLUSTER=demo-cluster
export GCP_ZONE=europe-west2-a
export GCP_REGION=europe-west2
export GCP_PROJECT=ejmadkins-anthos-platform
export DATA_DIR=/data
export DATA_VOLUME=data-volume
export SIDECAR_IMAGE_TAG=0.6.4

# create GKE cluster
gcloud container clusters create $KUBE_CLUSTER \
--num-nodes 3 \
--zone $my_zone \
--scopes=cloud-platform \
--enable-ip-alias

# get the credentials
gcloud container clusters get-credentials $KUBE_CLUSTER

# configure kubectl tab completion
source <(kubectl completion bash)

# apply appropriate permissions to deploy Prometheus
kubectl create clusterrolebinding owner-cluster-admin-binding \
--clusterrole cluster-admin \
--user=$(gcloud info --format='value(config.account)')

# create a dedicated namespace
kubectl create namespace prometheus

# create cluster role
kubectl create -f cluster-role.yaml

# create cluster role binding
kubectl create -f cluster-role-binding.yaml

# create ConfigMap
kubectl create -f config-map.yaml -n prometheus

# create prometheus deployment
kubectl create -f deployment.yaml -n prometheus

# get the pod name
kubectl get pods -n prometheus

# port forward to prometheus
kubectl port-forward <pod-name> 8080:9090 -n prometheus

# use web preview in cloud shell
# create the service
kubectl apply -f service.yaml

# open firewall ports
gcloud compute firewall-rules create test-node-port --allow tcp:32387,30182

# execute script to deploy the stackdriver collector
sh ./patch.sh deployment prometheus-deployment

# verify that the stackdriver collector is installed
kubectl -n prometheus get deployment prometheus-k8s -o=go-template='{{range .spec.template.spec.containers}}{{if eq .name "stackdriver-prometheus-sidecar"}}{{$output = (print "stackdriver-prometheus-sidecar exists. Image: " .image)}}{{end}}{{printf $output}}{{"\n"}}'

# verify the prometheus deployment
kubectl get pods -n prometheus


kubectl -n prometheus get deployment prometheus-k8s -o=go-template='
{{range .spec.template.spec.containers}}{{if eq .name "stackdriver-prometheus-sidecar"}}
{{$output = (print "stackdriver-prometheus-sidecar exists. Image: " .image)}}{{end}}{{end}}{{printf $output}}{{"\n"}}'


