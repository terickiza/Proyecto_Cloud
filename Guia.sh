--
##INSTALACION DE DOCKER
#INSTALACION DE KUBCTL
sudo apt-get update
sudo apt-get install -y kubectl
sudo snap install kubectl --clasic
--
#iNSTALACIÓN DE AZURE CLI EN UBUNTU SERVER
sudo apt-get update
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture)] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-get update
sudo apt-get install azure-cli
#Comandos para iniciar sesión en Azure CLI
az version
#Iniciar sesión en Azure CLI utilizando el código de dispositivo
az login --use-device-code
--
#Subir la imagen a ACR | ESTRUCTURA
az login
az acr login --name <nombre-del-registro>
docker tag <nombre-de-la-imagen>:<tag> <nombre-del-registro>.azurecr.io/<nombre-de-la-imagen>:<tag>
docker push <nombre-del-registro>.azurecr.io/<nombre-de-la-imagen>:<tag>  
#Ejemplo
az login
az acr login --name 08tcscloudlab.azurecr.io
docker tag riksys/tcs-cloud-project:v1 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1
docker push 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1
az acr repository list --name 08tcscloudlab -o table  #Listar los repositorios en el registro de contenedores
docker pull 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1  #Descargar la imagen desde el registro de contenedores
#Listar ACR
az acr list -o table
--
#Cargar imagen de ACR para AKS
az aks show \                       #Validar que el clúster de AKS tiene acceso al registro de contenedores
  --resource-group rg-cloud-lab \
  --name 08tcscloudlab-aks-dev \
  --query "servicePrincipalProfile"
  #Habilitar admin en el registro de contenedores
az acr update \
  --name 08tcscloudlab \
  --admin-enabled true

  #Ver usuario y clave del ACR
  az acr credential show \
  --name 08tcscloudlab \
  --query "{username:username, password:passwords[0].value}"
        #"password": "3qo42tb7D7iwbZ9UYqy6cxq8EAxJK0FTWNiDq9x7t9n6bArZunmRJQQJ99CBACYeBjFEqg7NAAACAZCRTCg4",
        #"username": "08tcscloudlab"
#Dar acceso al clúster de AKS al registro de contenedores
az aks update \
  --resource-group rg-cloud-lab \
  --name 08tcscloudlab-aks-dev \
  --attach-acr 08tcscloudlab
--
#Crear un secreto de Kubernetes para acceder al registro de contenedores
kubectl create secret docker-registry acr-secret \
  --docker-server=08tcscloudlab.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password>
    #Ejemplo    
kubectl create secret docker-registry acr-secret \
  --docker-server=08tcscloudlab.azurecr.io \
  --docker-username=08tcscloudlab \
  --docker-password=3qo42tb7D7iwbZ9UYqy6cxq8EAxJK0FTWNiDq9x7t9n6bArZunmRJQQJ99CBACYeBjFEqg7NAAACAZCRTCg4    
 #Descargar credenciales del AKS
az aks get-credentials \
  --resource-group rg-cloud-lab \
  --name 08tcscloudlab-aks-dev
#Verificar que el clúster de AKS tiene acceso al registro de contenedores
kubectl get secret acr-secret 
--
#Exponer el depliegue como un servicio de tipo LoadBalancer para acceder a la aplicación desde el exterior del clúster
kubectl expose deployment tcs-cloud-project \
  --type=LoadBalancer \
  --port 80 \
  --target-port 5000
--
kubectl get nodes #Listar los nodos en el clúster de Kubernetes

##PODS
kubectl get pods #Listar los pods en el clúster de Kubernetes
kubectl get svc #Listar los servicios en el clúster de Kubernetes
kubectl get deployments #Listar los despliegues en el clúster de Kubernetes
kubectl describe pod <nombre-del-pod> #Obtener detalles de un pod específico
kubectl logs <nombre-del-pod> #Ver los logs de un pod específico
kubectl exec -it <nombre-del-pod> -- /bin/bash #Acceder a un pod específico y ejecutar comandos dentro de él

#TEST
curl -X POST http://20.115.252.13/DevOps \
  -H "Content-Type: application/json" \
  -d '{
        "message": "Hola",
        "to": "Erick",
        "from": "TCS Cloud Project",
        "timeToLifeSec": 45
      }'
