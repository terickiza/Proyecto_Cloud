#!/bin/bash

################################################################################
#                  TCS CLOUD PROJECT - GUIA DE INSTALACION                    #
#                                                                              #
#  Este script contiene todos los pasos necesarios para desplegar la          #
#  infraestructura de TCS Cloud Project en Azure AKS usando Docker            #
#  y herramientas de línea de comandos.                                       #
#                                                                              #
#  Versión: 1.0 | Fecha: Febrero 2026                                         #
################################################################################


################################################################################
# SECCION 1: INSTALACION DE PREREQUISITOS EN UBUNTU SERVER
################################################################################

echo "============================================================================"
echo " 1. INSTALACION DE DOCKER"
echo "============================================================================"

# Preparar el sistema para la instalación de Docker
sudo apt-get update   
sudo apt install -y ca-certificates curl gnupg lsb-release

# Agregar la clave GPG de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmour -o /etc/apt/keyrings/docker.gpg

# Agregar el repositorio de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker Engine, CLI y complementos
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Habilitar y arrancar Docker
sudo systemctl enable --now docker

# Configurar usuario para ejecutar Docker sin sudo
sudo usermod -aG docker $USER
newgrp docker

# Verificar instalación
docker version
docker run --rm hello-world


echo "============================================================================"
echo " 2. INSTALACION DE KUBECTL"
echo "============================================================================"

sudo apt-get update
sudo apt-get install -y kubectl
# Alternativa con snap:
# sudo snap install kubectl --classic

# Verificar instalación
kubectl version --client


echo "============================================================================"
echo " 3. INSTALACION DE AZURE CLI EN UBUNTU SERVER"
echo "============================================================================"

sudo apt-get update
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg

# Agregar clave de Microsoft
curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

# Agregar repositorio de Azure CLI
echo "deb [arch=$(dpkg --print-architecture)] \
  https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/azure-cli.list

# Instalar Azure CLI
sudo apt-get update
sudo apt-get install -y azure-cli

# Verificar instalación
az version


################################################################################
# SECCION 2: AUTENTICACION EN AZURE
################################################################################

echo "============================================================================"
echo " 4. AUTENTICACION EN AZURE CLI"
echo "============================================================================"

# Iniciar sesión en Azure (con código de dispositivo)
az login --use-device-code

# Seleccionar suscripción si es necesario
# az account set --subscription "<subscription-id>"

# Verificar suscripción activa
az account show


################################################################################
# SECCION 3: TRABAJAR CON AZURE CONTAINER REGISTRY (ACR)
################################################################################

echo "============================================================================"
echo " 5. SUBIR IMAGEN A AZURE CONTAINER REGISTRY (ACR)"
echo "============================================================================"

# PASO 1: Login en Azure y ACR
az login
az acr login --name <nombre-del-registro>

# PASO 2: Etiquetar imagen de Docker
# Estructura: <nombre-del-registro>.azurecr.io/<nombre-imagen>:<tag>
docker tag <nombre-imagen:tag> <nombre-registro>.azurecr.io/<nombre-imagen>:<tag>

# PASO 3: Hacer push de la imagen al ACR
docker push <nombre-registro>.azurecr.io/<nombre-imagen>:<tag>

# EJEMPLO PRACTICO:
# ─────────────────────────────────────────────────────────────────────
az login
az acr login --name 08tcscloudlab
docker tag riksys/tcs-cloud-project:v1 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1
docker push 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1

# Listar repositorios en ACR
az acr repository list --name 08tcscloudlab -o table

# Descargar imagen desde ACR
docker pull 08tcscloudlab.azurecr.io/riksys/tcs-cloud-project:v1

# Listar todos los ACR en la suscripción
az acr list -o table


echo "============================================================================"
echo " 6. CONECTAR ACR CON AKS"
echo "============================================================================"

# PASO 1: Validar acceso del clúster AKS al registro
az aks show \
  --resource-group rg-cloud-lab \
  --name aks-e08 \
  --query "servicePrincipalProfile"

# PASO 2: Habilitar admin en el registro de contenedores
az acr update \
  --name 08tcscloudlab \
  --admin-enabled true

# PASO 3: Obtener credenciales del ACR
az acr credential show \
  --name 08tcscloudlab \
  --query "{username:username, password:passwords[0].value}"

# PASO 4: Dar acceso a AKS para usar el ACR
az aks update \
  --resource-group rg-cloud-lab \
  --name aks-e08 \
  --attach-acr 08tcscloudlab


echo "============================================================================"
echo " 7. CREAR SECRETO DE KUBERNETES PARA ACR"
echo "============================================================================"

# Crear secreto docker-registry para acceso a ACR desde Kubernetes
kubectl create secret docker-registry acr-secret \
  --docker-server=08tcscloudlab.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password>

# EJEMPLO CON VALORES REALES:
kubectl create secret docker-registry acr-secret \
  --docker-server=08tcscloudlab.azurecr.io \
  --docker-username=08tcscloudlab \
  --docker-password=<password-aqui>

# Verificar que el secreto fue creado
kubectl get secret acr-secret


################################################################################
# SECCION 4: CONFIGURAR AKS Y DESCARGAR CREDENCIALES
################################################################################

echo "============================================================================"
echo " 8. DESCARGAR CREDENCIALES DE AKS"
echo "============================================================================"

# Obtener kubeconfig para conectarse a AKS
az aks get-credentials \
  --resource-group rg-cloud-lab \
  --name aks-e08

# Verificar conexión a Kubernetes
kubectl cluster-info
kubectl get nodes


################################################################################
# SECCION 5: DESPLEGAR APLICACION EN AKS
################################################################################

echo "============================================================================"
echo " 9. DESPLEGAR APLICACION (DEPLOYMENT Y SERVICIO)"
echo "============================================================================"

# OPCION 1: Usar archivo YAML (RECOMENDADO)
kubectl apply -f deployment_ms01.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml

# OPCION 2: Exponer deployment como LoadBalancer (alternativa)
kubectl expose deployment tcs-cloud-project \
  --type=LoadBalancer \
  --port 80 \
  --target-port 5000


################################################################################
# SECCION 6: MONITOREO Y DIAGNOSTICO
################################################################################

echo "============================================================================"
echo " 10. COMANDOS DE MONITOREO EN KUBERNETES"
echo "============================================================================"

# --- NODOS ---
kubectl get nodes                          # Listar nodos del clúster
kubectl describe node <nombre-nodo>        # Detalles de un nodo

# --- PODS ---
kubectl get pods                           # Listar todos los pods
kubectl get pods -A                        # Listar pods en todos los namespaces
kubectl describe pod <nombre-pod>          # Detalles de un pod específico
kubectl logs <nombre-pod>                  # Ver logs de un pod
kubectl logs <nombre-pod> -f               # Ver logs en tiempo real
kubectl exec -it <nombre-pod> -- /bin/bash # Acceder a un pod interactivamente

# --- SERVICIOS Y DEPLOYMENTS ---
kubectl get svc                            # Listar servicios
kubectl get deployments                    # Listar deployments
kubectl describe svc <nombre-svc>          # Detalles de un servicio
kubectl describe deployment <nombre-dep>   # Detalles de un deployment

# --- RECURSOS GENERALES ---
kubectl get all                            # Ver todos los recursos
kubectl top nodes                          # Uso de recursos en nodos
kubectl top pods                           # Uso de recursos en pods


################################################################################
# SECCION 7: PRUEBAS DE LA API
################################################################################

echo "============================================================================"
echo " 11. PRUEBAS DE LA API REST"
echo "============================================================================"

# Obtener IP externa del LoadBalancer (EXTERNAL-IP)
kubectl get svc tcs-cloud-project

# TEST: POST a endpoint /DevOps
# Reemplazar <IP-PUBLICA> con la IP obtenida del LoadBalancer
curl -X POST http://<IP-PUBLICA>/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hola",
    "to": "Erick",
    "from": "TCS Cloud Project",
    "timeToLifeSec": 45
  }'

# EJEMPLO CON IP REAL:
curl -X POST http://20.115.252.13/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Hola",
    "to": "Erick",
    "from": "TCS Cloud Project",
    "timeToLifeSec": 45
  }'


################################################################################
# NOTAS Y REFERENCIAS
################################################################################

# ORDEN DE DESPLIEGUE:
# 1. Ejecutar terraform en carpeta "2. Network" (crear VNet y Subnet)
# 2. Ejecutar terraform en carpeta "3. AKS" (crear cluster AKS)
# 3. Ejecutar comandos de esta guía o kubectl para desplegar aplicación

# DOCUMENTACION:
# - Ver README en cada carpeta (1. App, 2. Network, 3. AKS)
# - Docker docs: https://docs.docker.com
# - Kubernetes docs: https://kubernetes.io/docs
# - Azure docs: https://docs.microsoft.com/azure

# SOPORTE:
# Contacto: erick.iza@tcs-ecu.com
# Proyecto: TCS Cloud Project 2026

################################################################################
