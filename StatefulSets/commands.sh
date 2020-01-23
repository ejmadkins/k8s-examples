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
