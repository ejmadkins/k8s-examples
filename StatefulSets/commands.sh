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

# create service
kubectl apply -f service.yaml

# create StatefulSet
kubectl apply -f StatefulSet.yaml

# verify pods are created sequentially and in order
kubectl get pods -w -l app=nginx

# view the service
kubectl get service nginx

# view the StatefulSet
kubectl get statefulset web

# view the pods ordinal index
kubectl get pods -l app=nginx

# pods have a stable hostname based on the ordinal index
for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done

# execute container that provides the nslookup command using dnsutils package
kubectl run -i --tty --image busybox:1.28 dns-test --restart=Never --rm  
nslookup web-0.nginx
nslookup web-1.nginx

# term 1 - StatefulSet will restart the pods
kubectl get pod -w -l app=nginx

# term 2
kubectl delete pod -l app=nginx

# execute container that provides the nslookup command using dnsutils package
for i in 0 1; do kubectl exec web-$i -- sh -c 'hostname'; done

# The Pods’ ordinals, hostnames, SRV records, and A record names have not changed, but the IP addresses associated with the Pods may have changed. This is why it is important not to configure other applications to connect to Pods in a StatefulSet by IP address.

# If you need to find and connect to the active members of a StatefulSet, you should query the CNAME of the Headless Service (nginx.default.svc.cluster.local). The SRV records associated with the CNAME will contain only the Pods in the StatefulSet that are Running and Ready.

# If your application already implements connection logic that tests for liveness and readiness, you can use the SRV records of the Pods ( web-0.nginx.default.svc.cluster.local, web-1.nginx.default.svc.cluster.local), as they are stable, and your application will be able to discover the Pods’ addresses when they transition to Running and Ready

# view the PVCs
kubectl get pvc -l app=nginx

# write the pods hostnames to index.html
for i in 0 1; do kubectl exec web-$i -- sh -c 'echo $(hostname) > /usr/share/nginx/html/index.html'; done
for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done

# term 1 - watch the pods
kubectl get pod -w -l app=nginx

# term 2 - delete the pods
kubectl delete pod -l app=nginx

# term 2 - verify web servers serve their hostnames
for i in 0 1; do kubectl exec -it web-$i -- curl localhost; done
