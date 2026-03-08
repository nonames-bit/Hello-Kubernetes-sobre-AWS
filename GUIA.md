# Guía: Hello Kubernetes sobre AWS
> Para ingenieros de automatización que comienzan en la nube

---

## ¿Qué construimos?

Desplegamos una **API de suma** (microservicio) en la nube de Amazon, de forma que cualquier persona en internet pueda llamarla. Todo el proceso fue automatizado con código — nada se hizo a mano en la consola de AWS.

```
Tu computador
     │
     │  (llamas a la API)
     ▼
Internet
     │
     ▼
┌─────────────────────────────────────────────────────┐
│                      AWS                            │
│                                                     │
│   Load Balancer ──► Pod (contenedor) ──► App Python │
│   (puerta de       (corre dentro         (calcula   │
│    entrada)         del nodo EC2)         la suma)  │
│                                                     │
│   Todo esto vive dentro del cluster EKS             │
└─────────────────────────────────────────────────────┘
```

---

## Las herramientas que usamos

### 1. Terraform — el "PLC" de la infraestructura

Como ingeniero de automatización, ya programas PLCs para controlar máquinas. **Terraform hace lo mismo pero para servidores en la nube**: le describes qué quieres tener y él lo crea automáticamente.

```
Tu código Terraform          Lo que crea en AWS
─────────────────────        ──────────────────
resource "aws_eks_cluster"   ──►  Cluster Kubernetes
resource "aws_eks_node_group"──►  Máquinas virtuales (EC2)
resource "aws_security_group"──►  Reglas de firewall
```

**Archivos clave de Terraform en este proyecto:**

```
terraform/
├── stacks/eks/              ← "el programa principal"
│   ├── main.tf              ← qué recursos crear (llama al módulo)
│   ├── variables.tf         ← qué parámetros acepta
│   ├── outputs.tf           ← qué información devuelve al final
│   └── config.tf            ← configuración del provider AWS y backend S3
│
├── modules/eks/             ← "función reutilizable"
│   ├── main.tf              ← lógica del cluster EKS
│   ├── data.tf              ← consulta datos de AWS (VPC, subnets, roles)
│   ├── locals.tf            ← variables internas calculadas
│   ├── variables.tf         ← parámetros del módulo
│   └── outputs.tf           ← lo que expone el módulo
│
└── environments/student/eks/
    ├── terraform.tfvars     ← TUS valores (nombre cluster, región, etc.)
    └── backend.tfvars       ← dónde guardar el estado (bucket S3)
```

**¿Por qué existe la carpeta `modules`?**
Es como una función en programación: escribes la lógica una sola vez y la llamas con distintos parámetros. Si mañana quieres otro cluster con otro nombre, solo cambias el `.tfvars`.

---

### 2. EKS — el "sistema SCADA" de los contenedores

**EKS** (Elastic Kubernetes Service) es el servicio de Amazon para manejar contenedores. Piénsalo como un SCADA que supervisa y mantiene vivos tus procesos:

```
EKS (el supervisor)
 │
 ├── Node Group: máquinas virtuales EC2 (los "PCs de campo")
 │    └── Nodo: ip-172-31-63-66 (1 × t3.medium, 2 vCPU, 4GB RAM)
 │         └── Pod: contenedor con tu aplicación corriendo
 │
 └── Control Plane: el cerebro que decide dónde corre cada cosa
      (gestionado por Amazon, tú no tienes que preocuparte)
```

**¿Qué es un Pod?**
Un Pod es la unidad mínima de Kubernetes. Contiene uno o más contenedores Docker. En nuestro caso: 1 pod = 1 contenedor con la API de suma.

---

### 3. ECR — el repositorio de imágenes Docker

**ECR** (Elastic Container Registry) es como un "almacén de programas" privado dentro de AWS. Guardamos ahí la imagen Docker de nuestra app y Kubernetes la descarga desde ahí.

```
Dockerfile  ──► docker build ──► Imagen ──► ECR ──► EKS la descarga
(receta)                        (paquete)  (almacén)  y la ejecuta
```

La imagen que usamos:
```
621000620703.dkr.ecr.us-east-1.amazonaws.com/calculadora/suma:1.0.0
│             │                              │           │    │
└─ cuenta AWS └─ región                      └─ repo     └─app └─versión
```

---

### 4. Kubernetes (K8s) — el orquestador

Kubernetes es quien decide **cómo y dónde** corren los contenedores. Lo controlamos con archivos YAML.

**Nuestro archivo `k8s/k8s_deployment_service.yaml` tiene dos partes:**

#### Parte 1: Deployment (el proceso)
```yaml
kind: Deployment        # "quiero que este proceso esté siempre corriendo"
spec:
  replicas: 1           # 1 instancia (puedes poner más para redundancia)
  containers:
    - image: ...ecr.../calculadora/suma:1.0.0   # la imagen a usar
      resources:
        requests:
          memory: "64Mi"   # mínimo garantizado (como reservar RAM en un PLC)
          cpu: "250m"      # 250 milicores = 0.25 núcleos
        limits:
          memory: "128Mi"  # máximo antes de reiniciar el pod
          cpu: "500m"      # máximo de CPU
      ports:
        - containerPort: 4000   # el puerto interno de la app
```

#### Parte 2: Service tipo LoadBalancer (la puerta de entrada)
```yaml
kind: Service
spec:
  type: LoadBalancer    # AWS crea un balanceador de carga externo automáticamente
  ports:
    - port: 80          # puerto público (HTTP estándar)
      targetPort: 4000  # lo redirige al puerto interno del contenedor
```

**¿Por qué LoadBalancer?**
Es como tener una IP pública fija que siempre apunta a tu servicio, aunque los contenedores internos cambien o se reinicien.

---

### 5. El flujo completo que ejecutamos

```
PASO 1: Infraestructura con Terraform
──────────────────────────────────────
terraform init    ← descarga providers y configura backend S3
terraform plan    ← "¿qué vas a crear?" (sin crear nada aún)
terraform apply   ← crea todo en AWS

        Resultado: Cluster EKS + Nodo EC2 + Seguridad


PASO 2: Conectar kubectl al cluster
─────────────────────────────────────
aws eks update-kubeconfig --name tutorial-dann-cluster --region us-east-1

        Resultado: kubectl sabe hablar con TU cluster


PASO 3: Desplegar la aplicación
────────────────────────────────
kubectl apply -f k8s/k8s_deployment_service.yaml

        Resultado: Pod corriendo + LoadBalancer con URL pública


PASO 4: Probar
───────────────
curl -X POST http://<EXTERNAL-IP>/suma \
  -H "Content-Type: application/json" \
  -d '{"num_1": 399, "num_2": 1}'

        Resultado: {"message": "...la suma es: 400", "result": 400}
```

---

### 6. El estado de Terraform (tfstate)

Terraform guarda un archivo llamado `terraform.tfstate` en un **bucket S3** (`bukettallerk8`). Este archivo es su "memoria": sabe qué recursos ya creó para no volver a crearlos.

```
Terraform ──lee/escribe──► S3: bukettallerk8/eks/terraform.tfstate
                                │
                                └─ contiene: IDs de todos los recursos creados
```

> ⚠️ Nunca borres este archivo. Si lo pierdes, Terraform "olvida" lo que creó
> y la próxima vez intentará crear todo de nuevo (duplicado).

---

### 7. Comandos útiles para el día a día

```bash
# Ver el estado del cluster
kubectl get nodes

# Ver los pods corriendo
kubectl get pods

# Ver los servicios (y la IP pública)
kubectl get services

# Ver los logs de tu aplicación
kubectl logs <nombre-del-pod>

# Actualizar la aplicación (nueva imagen)
kubectl set image deployment/suma suma=<nueva-imagen>

# Escalar a más réplicas
kubectl scale deployment suma --replicas=3

# Destruir todo (¡cuidado!)
terraform destroy -var-file="../../environments/student/eks/terraform.tfvars"
```

---

### 8. Analogía final para un ingeniero de automatización

| Automatización Industrial | Nube con Kubernetes |
|--------------------------|---------------------|
| PLC | Pod (contenedor) |
| SCADA | Kubernetes (EKS) |
| Red industrial | VPC + Subnets |
| Firewall/ACL | Security Groups |
| Receta de proceso | Dockerfile |
| Programa del PLC | Código Python (app) |
| Servidor OPC-UA | LoadBalancer Service |
| Respaldo del programa | tfstate en S3 |
| Terraform | PLC Programming software (TIA Portal, Studio 5000) |

---

*Proyecto: Hello Kubernetes sobre AWS — Maestría IA, Desarrollo de Apps Nativas en la Nube*
