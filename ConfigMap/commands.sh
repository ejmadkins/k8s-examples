# build and run container
docker build -t flask-app:latest flask-app/
docker run -d -p 5000:5000 flask-app

# set env variables
export project_id=<id>
export my_zone=europe-west2-a
export my_cluster=demo-container

# submit container to cloud builder
gcloud builds submit --tag gcr.io/$project_id/flask-app flask-app/

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

# apply the ConfigMap for dev and prod
kubectl apply -f config-map-dev.yaml; kubectl apply -f config-map-prod.yaml

# apply the ConfigMap for dev and prod
cat deployment-dev.yaml | sed "s/IMAGE/$project_id/g" | kubectl apply -f -
cat deployment-prod.yaml | sed "s/IMAGE/$project_id/g" | kubectl apply -f -

# verify deployments
kubectl get configmaps -n dev-environment
kubectl get configmaps -n prod-environment

# verify deployments
kubectl get all -n dev-environment -o wide
kubectl get all -n prod-environment -o wide

# create a firewall rule to allow a connection to the nodeport
gcloud compute firewall-rules create sharky-app --allow tcp:80

# connect to the pod
kubectl exec -it -n dev-environment sharky-app -- sh

# check environment variables
echo $ENV; echo $TITLE; echo $PIC; echo $NAME;

# connect to the pod
kubectl exec -it -n prod-environment sharky-app -- sh

# check environment variables
echo $ENV; echo $TITLE; echo $PIC; echo $NAME;

# curl from your local machine to the node IP and port
curl http://[lb_ip]:[node_port]
