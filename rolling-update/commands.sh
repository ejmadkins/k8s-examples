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

# create deployment
kubectl create -f deployment.yaml

# connect to the pod
kubectl exec -it [POD] -- sh

# install curl
apk add --no-cache curl

# verify deployments
kubectl describe deployments

# update the deployment
kubectl set image deployments/nginx nginx=nginx:1.9.1

# verify that the pods have updated
kubectl get pods

# verify the deployment
kubectl rollout status deployments/nginx

# update the deployment
kubectl set image deployments/nginx nginx=nginx:6.6.6

# verify the deployment
kubectl rollout status deployments/nginx

# verify that the pods have failed as nginx:6.6.6 doesn't exist
kubectl get pods

# undo the update
kubectl rollout undo deployments/nginx

# verify the rollback
kubectl rollout status deployments/nginx

# tidy up
kubectl delete deployment nginx