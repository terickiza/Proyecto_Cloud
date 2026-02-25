# DevOps Microservice - RESTAPI

Microservicio REST ligero y seguro basado en **Flask** para demostración en laboratorio de Cloud. Implementa validación estricta de solicitudes POST al endpoint `/DevOps` con contrato de API bien definido.

---

## 📋 Descripción General

Aplicación Python que expone un único endpoint REST (`/DevOps`) que:

- ✅ Acepta solo solicitudes **POST** con estructura JSON específica
- ✅ Valida campos obligatorios: `message`, `to`, `from`, `timeToLifeSec`
- ✅ Rechaza solicitudes con datos inválidos, campos faltantes o extras
- ✅ Retorna respuestas JSON estructuradas
- ✅ Preparada para despliegue en **Docker** y **Kubernetes (AKS)**
- ✅ Pronta para integración con **API Management (APIM)** y pasarelas de red

### Casos de Uso

- 🎯 Laboratorio en Azure (TCS Cloud Project)
- 🔒 Validación de tokens JWT y API Keys en APIM
- 📦 Microservicio containerizado en AKS con NGINX Ingress
- 🚀 Pipeline CI/CD en Azure DevOps

---

## 🏗️ Estructura de Carpeta

```
1. App/
├── app.py              # Aplicación principal (Flask)
├── requirements.txt    # Dependencias Python
├── Dockerfile          # Configuración para Docker
├── deployment_ms01.yaml  # Manifiesto Kubernetes (Deployment)
└── README.md           # Este archivo
```

---

## 🔌 Especificación del API

### Endpoint: `/DevOps`

| Propiedad | Valor |
|-----------|-------|
| **Método HTTP** | `POST` |
| **Content-Type** | `application/json` |
| **Puerto** | `5000` (local) / `8080` (Kubernetes) |
| **Autenticación** | Manejada por APIM (headers X-Parse-REST-API-Key, X-JWT-KWY) |

### Estructura de Solicitud (Request Body)

```json
{
  "message": "This is a test",
  "to": "Juan Perez",
  "from": "Rita Asturia",
  "timeToLifeSec": 45
}
```

**Validaciones:**
- `message`: string (obligatorio, no vacío)
- `to`: string (obligatorio, no vacío)
- `from`: string (obligatorio, no vacío)
- `timeToLifeSec`: integer (obligatorio, > 0)
- ❌ No se aceptan campos adicionales

### Estructura de Respuesta (Response)

#### ✅ Éxito (HTTP 200)
```json
{
  "message": "Hello Juan Perez your message will be sent"
}
```

#### ❌ Error (HTTP 400/405)
```json
{
  "error": "ERROR"
}
```

---

## 🚀 Instalación y Ejecución Local

### Requisitos Previos

- **Python** 3.7 o superior
  ```bash
  python --version
  ```

- **pip** (gestor de paquetes Python)
  ```bash
  pip --version
  ```

### Paso 1: Instalar Dependencias

```bash
cd "1. App"
pip install -r requirements.txt
```

**Contenido de `requirements.txt`:**
```
Flask==2.3.0
Werkzeug==2.3.0
```

### Paso 2: Ejecutar la Aplicación

```bash
python app.py
```

**Salida esperada:**
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

### Paso 3: Verificar que está activo

```bash
curl http://localhost:5000/healthz
```

---

## 🧪 Pruebas Completas

### ✅ Solicitud Válida (HTTP 200 OK)

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45
  }'
```

**Respuesta esperada:**
```json
{
  "message": "Hello Juan Perez your message will be sent"
}
```

---

### ❌ Método HTTP Incorrecto (HTTP 405)

```bash
curl -X GET http://localhost:5000/DevOps
curl -X PUT http://localhost:5000/DevOps
curl -X DELETE http://localhost:5000/DevOps
```

**Respuesta esperada:**
```json
{
  "error": "ERROR"
}
```

---

### ❌ Body Inválido - Campos Faltantes

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test"
  }'
```

**Respuesta esperada:**
```json
{
  "error": "ERROR"
}
```

---

### ❌ Body Inválido - Campos Extras

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45,
    "extra_field": "no permitido"
  }'
```

**Respuesta esperada:**
```json
{
  "error": "ERROR"
}
```

---

### ❌ Body Inválido - Tipos de Datos Incorrectos

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": "45"
  }'
```

**Respuesta esperada:**
```json
{
  "error": "ERROR"
}
```

---

### ❌ Body Inválido - Campos Vacíos

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45
  }'
```

**Respuesta esperada:**
```json
{
  "error": "ERROR"
}
```

---

## 🐳 Docker

### Construir Imagen Docker

```bash
docker build -t devops-microservice:1.0 .
```

**Dockerfile incluye:**
- Imagen base: `python:3.9-slim` (ligera)
- Puerto expuesto: `5000`
- Comando: `python app.py`

### Ejecutar Contenedor Localmente

```bash
docker run -d \
  --name devops-ms \
  -p 5000:5000 \
  devops-microservice:1.0
```

### Probar desde Docker

```bash
curl -X POST http://localhost:5000/DevOps \
  -H "Content-Type: application/json" \
  -d '{
    "message": "This is a test",
    "to": "Juan Perez",
    "from": "Rita Asturia",
    "timeToLifeSec": 45
  }'
```

### Subir a Azure Container Registry (ACR)

```bash
# Autenticarse en el registro
az acr login --name acrtcsdevopsdev01

# Etiquetar imagen
docker tag devops-microservice:1.0 \
  acrtcsdevopsdev01.azurecr.io/devops-microservice:1.0

# Push a ACR
docker push acrtcsdevopsdev01.azurecr.io/devops-microservice:1.0

# Verificar
az acr repository show \
  --name acrtcsdevopsdev01 \
  --repository devops-microservice
```

---

## ☸️ Kubernetes (AKS)

### Desplegar en AKS

```bash
kubectl apply -f deployment_ms01.yaml
```

**El archivo `deployment_ms01.yaml` incluye:**
- Deployment: 2 replicas
- Service: ClusterIP (interno)
- Ingress: Ruta `/DevOps`
- Health Checks: readinessProbe + livenessProbe
- Resources: límites de CPU y memoria
- Selecciones de nodos: `poolapps`

### Verificar Despliegue

```bash
# Ver deployments
kubectl get deployments

# Ver pods
kubectl get pods

# Ver servicios
kubectl get svc

# Ver logs de un pod
kubectl logs -f <pod-name> -c tcsapp

# Acceder a un pod
kubectl exec -it <pod-name> -- /bin/bash
```

### Buenas Prácticas

✅ Validación estricta de input  
✅ Respuestas JSON genéricas (sin stack trace)  
✅ Health checks en Kubernetes  
✅ Límites de recursos (CPU, memoria)  
✅ Logs estructurados (para monitoreo)  
✅ Sin datos sensibles en logs  

---

## 🐛 Troubleshooting

| Problema | Causa | Solución |
|----------|-------|----------|
| `ConnectionRefusedError: 111` | Aplicación no está corriendo | `python app.py` |
| `400 Bad Request` | Body JSON inválido | Validar sintaxis JSON |
| `405 Method Not Allowed` | Método HTTP incorrecto (no POST) | Usar `curl -X POST` |
| `{"error": "ERROR"}` | Validación fallida | Revisar estructura del body |
| `ModuleNotFoundError: No module named 'flask'` | Dependencias no instaladas | `pip install -r requirements.txt` |

---

## 📚 Enlaces Referencias

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Azure Container Registry (ACR)](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Kubernetes Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [Azure API Management (APIM)](https://docs.microsoft.com/en-us/azure/api-management/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---

## 👤 Autor y Versión

- **Versión**: 1.1
- **Creado**: 2024
- **Actualizado**: Febrero 2026
- **Propietario**: erick.iza
- **Equipo**: TCS Cloud Project

---

## 📄 Licencia

Parte del laboratorio **TCS Cloud Project** - Laboratorio de Azure.

---

## 📞 Soporte

Para problemas o reports:
1. Validar aplicación localmente: `python app.py`
2. Revisar logs de Kubernetes: `kubectl logs`
3. Consultar documentación de Azure

---

**Última actualización**: 24 de febrero de 2026
