# Tutorial Hello Kubernetes

Referencia rápida de comandos
Todos los comandos del tutorial en un solo lugar para consulta rápida.

Terraform
Comando	¿Qué hace?
terraform init -backend-config=…	Inicializa el proyecto, descarga providers y módulos, conecta al backend S3.
terraform plan -var-file=… -out=.tfplan	Genera y guarda el plan de cambios (sin ejecutar nada en AWS).
terraform apply .tfplan	Aplica el plan: crea/modifica/elimina infraestructura en AWS.
terraform destroy -var-file=…	Elimina TODA la infraestructura gestionada por Terraform.
AWS CLI
Comando	¿Qué hace?
aws sts get-caller-identity	Verifica que tus credenciales AWS están activas y muestra tu cuenta.
aws eks update-kubeconfig --name …	Agrega el clúster EKS a la configuración local de kubectl.
kubectl — Gestión básica
Comando	¿Qué hace?
kubectl config current-context	Muestra a qué clúster apunta kubectl actualmente.
kubectl config use-context <nombre>	Cambia el clúster activo (ej: volver a minikube).
kubectl apply -f <archivo.yaml>	Despliega o actualiza los recursos descritos en el manifiesto YAML.
kubectl delete -f <archivo.yaml>	Elimina los recursos definidos en el manifiesto.
kubectl — Verificación de estado
Comando	¿Qué hace?
kubectl get pods	Lista todos los pods y su estado (Running, Pending, etc.).
kubectl get deployments	Lista los deployments y cuántas réplicas están activas.
kubectl get services	Lista los servicios, sus IPs (incluida la IP externa del LoadBalancer).
kubectl get nodes	Lista los nodos (VMs) del clúster y su estado.
kubectl — Troubleshooting
Comando	¿Qué hace?
kubectl describe pod <nombre>	Diagnóstico detallado de un pod: eventos, condiciones, razones de fallo.
kubectl logs <nombre> --all-containers	Ver los logs de salida del contenedor (stdout). Equivale al visor de mensajes del PLC.
kubectl get events	Lista todos los eventos recientes en el namespace. Primera parada para diagnosticar.
kubectl describe service <nombre>	Detalla config del servicio, endpoints y eventos asociados.
kubectl get pods -o wide	Muestra en qué nodo está corriendo cada pod.
