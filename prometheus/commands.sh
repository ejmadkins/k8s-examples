# set env variables
export project_id=ejmadkins-terraform
export my_region=europe-west2
export my_zone=europe-west2-a
export my_cluster=demo-container

# install the Stackdriver Collector to get those metrics exported to the Stackdriver backend, add env variables
export KUBE_NAMESPACE=prometheus
export KUBE_CLUSTER=$my_cluster
export GCP_REGION=$my_region
export GCP_PROJECT=$project_id
export DATA_DIR=/prometheus/
export DATA_VOLUME=prometheus-storage-volume
export SIDECAR_IMAGE_TAG=release-0.7.1

# create GKE cluster
gcloud container clusters create $my_cluster \
--num-nodes 3 \
--zone $my_zone \
--scopes=cloud-platform \
--enable-ip-alias

# get the credentials
gcloud container clusters get-credentials $my_cluster

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

# execute script to deploy the stackdriver collector
sh ./patch.sh deployment prometheus-deployment

# verify that the stackdriver collector is installed
kubectl -n "${KUBE_NAMESPACE}" get <deployment|statefulset> <name> -o=go-template='{{$output := "stackdriver-prometheus-sidecar does not exists."}}{{range .spec.template.spec.containers}}{{if eq .name "stackdriver-prometheus-sidecar"}}{{$output = (print "stackdriver-prometheus-sidecar exists. Image: " .image)}}{{end}}{{end}}{{printf $output}}{{"\n"}}'

# verify the prometheus deployment
kubectl get pods -n prometheus