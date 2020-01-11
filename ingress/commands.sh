# set env variables
export project_id=ejmadkins-terraform
export my_zone=europe-west2-a
export my_cluster=demo-container

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

# create deployments
kubectl create -f httpd-deployment.yaml
kubectl create -f lighttpd-deployment.yaml
kubectl create -f nginx-deployment.yaml

# create services
kubectl apply -f httpd-service.yaml
kubectl apply -f lighttpd-service.yaml
kubectl apply -f nginx-service.yaml

# create ingress
kubectl apply -f ingress.yaml

# verify ingress
kubectl get ingress ingress

# create a firewall rule to allow a connection to the nodeport
gcloud compute firewall-rules create test-node-port --allow tcp:32264

# curl from your local machine to the node IP and port
curl http://[node_ip]:[node_port]