# set env variables
export project_id=<id>
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
kubectl create -f helloworld-deployment.yaml
kubectl create -f nginx-deployment.yaml

# create services
kubectl apply -f httpd-service.yaml
kubectl apply -f helloworld-service.yaml
kubectl apply -f nginx-service.yaml

# create ingress
kubectl apply -f ingress.yaml

# verify ingress
kubectl get ingress ingress

# create a firewall rule to allow a connection to the GLB
gcloud compute firewall-rules create ingress --allow tcp:80

# curl from your local machine to the node IP and port
curl http://[ingress_glb_ip]
curl http://[ingress_glb_ip]/nginx
curl http://[ingress_glb_ip]/default-backend

# tidy up
kubectl delete deployment httpd
kubectl delete deployment helloworld
kubectl delete deployment nginx
kubectl delete service httpd-service
kubectl delete service helloworld-service
kubectl delete service nginx-service
kubectl delete ingress my-ingress
