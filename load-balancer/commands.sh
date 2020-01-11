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

# connect to the pod
kubectl exec -it [POD] -- sh

# install curl
apk add --no-cache curl

# create a firewall rule to allow a connection to the nodeport
gcloud compute firewall-rules create test-node-port --allow tcp:60000

# curl from your local machine to the node IP and port
curl http://[node_ip]:[node_port]

# verify the http-health-check
gcloud compute http-health-checks list

# verify the target-pool
gcloud compute target-pools list

# verify the forwarding rule
gcloud compute forwarding-rules list