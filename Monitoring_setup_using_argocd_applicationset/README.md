# Monitoring setup deployment using ArgoCD applicationset

This project aims to deploy a monitoring setup in Azure Kubernets cluster using Kustomize and ArgoCD. Then integrate Azure AD to log into the Grafana instance.



kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl get secret -n argocd argocd-initial-admin-secret -o=jsonpath='{.data.password}' |base64 -d


admin bqqf2MSovLEJsN-7

![alt text](images/image-1.png)

![alt text](images/image-2.png)

![alt text](images/image-3.png)

![alt text](images/image-4.png)

![alt text](images/image-5.png)

![alt text](images/image-19.png)

![alt text](images/image-7.png)

![alt text](images/image-8.png)


we need a https endpoint so we will go with clusterip and ingress

![alt text](images/image-9.png)

![alt text](images/image-10.png)

![alt text](images/image-11.png)

![alt text](images/image-12.png)


kubectl create secret generic -n grafana grafana-credentials \
  --from-literal=GF_AUTH_AZUREAD_CLIENT_ID=<azuread_client_id_value> \
  --from-literal=GF_AUTH_AZUREAD_CLIENT_SECRET=<azuread_client_secret_value>


![alt text](images/image-13.png)

![alt text](images/image-14.png)

![alt text](images/image-15.png)

![alt text](images/image-16.png)

In this way, all the users are accessed for the role 'Viewer' by default.



![alt text](images/image-17.png)

Include the terraform link also


![alt text](images/image-18.png)

