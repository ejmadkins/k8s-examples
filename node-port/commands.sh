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

# update deployment with cloud build image
sed 's/IMAGE/$project_id/g' deployment.yaml

# connect to the pod
kubectl exec -it flask-app-7f58c58ff7-4vq6g -- sh

# create a firewall rule to allow a connection to the nodeport
gcloud compute firewall-rules create test-node-port --allow tcp:32264

# curl from your local machine to the node IP and port
curl http://[node_ip]:[node_port]
