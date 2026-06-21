# AGENTS.md

## Propósito del proyecto

Este repositorio implementa una solución de Infraestructura como Código (IaC) utilizando Terraform y Google Cloud Platform (GCP) para desplegar una arquitectura de alta disponibilidad con balanceo de tráfico entre dos servicios independientes.

El objetivo principal es permitir que el comportamiento del sistema sea modificado únicamente cambiando variables de Terraform, sin necesidad de realizar cambios manuales en la consola de GCP.

---

# Tecnologías utilizadas

* Terraform
* Google Cloud Platform (GCP)
* Compute Engine
* VPC Networking
* Cloud Router
* Cloud NAT
* HTTP Load Balancer
* Health Checks
* Nginx

---

# Arquitectura implementada

```text
Internet
    │
    ▼
HTTP Load Balancer (IP pública)
    │
    ▼
─────────────────────────
│                       │
▼                       ▼
prod-vm             maintenance-vm
us-central1-a       us-central1-b
Sin IP pública      Sin IP pública
        │
        ▼
      Cloud NAT
        │
        ▼
     Internet
```

Características:

* Dos máquinas virtuales completamente independientes.
* Cada servicio reside en una zona distinta para aumentar la resiliencia.
* Las máquinas virtuales no poseen direcciones IP públicas.
* El único punto de entrada público es el Load Balancer.
* El acceso a Internet de las VMs se realiza mediante Cloud NAT.

---

# Estructura del proyecto

```text
provider.tf          -> Configuración del proveedor GCP.
variables.tf         -> Declaración de variables.
terraform.tfvars     -> Valores de las variables.
network.tf           -> VPC y subred.
firewall.tf          -> Reglas de firewall.
nat.tf               -> Cloud Router y Cloud NAT.
instances.tf         -> Máquinas virtuales e Instance Groups.
load_balancer.tf     -> Health Checks y Load Balancer.
outputs.tf           -> Salidas del proyecto.
startup/             -> Scripts de inicialización.
README.md            -> Documentación del usuario.
AGENTS.md            -> Documentación para agentes automáticos y LLMs.
```

---

# Flujo de despliegue

El despliegue se realiza en el siguiente orden:

1. Crear la VPC y la subred.
2. Crear el Cloud Router.
3. Crear el Cloud NAT.
4. Crear las máquinas virtuales.
5. Ejecutar los scripts de inicialización.
6. Crear los Instance Groups.
7. Crear el Health Check.
8. Crear el Backend Service.
9. Crear el HTTP Load Balancer.
10. Exponer una única IP pública.

Todo el despliegue se realiza con:

```bash
terraform apply
```

No se requiere ninguna configuración manual posterior.

---

# Variables principales

| Variable           | Descripción                       |
| ------------------ | --------------------------------- |
| project_id         | ID del proyecto de GCP            |
| region             | Región de despliegue              |
| prod_zone          | Zona de la VM de producción       |
| maintenance_zone   | Zona de la VM de mantenimiento    |
| prod_weight        | Peso del backend de producción    |
| maintenance_weight | Peso del backend de mantenimiento |

---

# Escenarios de evaluación

## Escenario 1 – Producción Activa

```hcl
prod_weight        = 100
maintenance_weight = 0
```

Resultado esperado:

```text
Bienvenido al Servicio Principal - Version Produccion
```

---

## Escenario 2 – Mantenimiento Total

```hcl
prod_weight        = 0
maintenance_weight = 100
```

Resultado esperado:

```text
Error 503 – Sitio en Mantenimiento Programado
```

---

## Escenario 3 – Balance Equitativo

```hcl
prod_weight        = 50
maintenance_weight = 50
```

Resultado esperado:

Las solicitudes deben distribuirse entre ambos servicios.

---

# Consideraciones importantes sobre el escenario 50/50

Durante las pruebas se observó que un simple refresco del navegador (F5) no siempre alterna entre ambos servicios. Este comportamiento es esperado y no representa un error de configuración.

## Motivo

Los navegadores modernos utilizan:

* Caché HTTP.
* Reutilización de conexiones (HTTP Keep-Alive).

El HTTP Load Balancer de Google Cloud puede reutilizar la misma conexión TCP, por lo que múltiples refrescos consecutivos pueden mostrar repetidamente el mismo backend.

Por esta razón:

* F5 no garantiza un cambio de servicio.
* Ctrl + F5 o Ctrl + Shift + R suelen generar mejores resultados.
* La forma recomendada de verificar el balanceo es mediante múltiples conexiones independientes.

---

# Método de validación recomendado

```powershell
1..20 | % {
    Start-Sleep -Milliseconds 500
    curl.exe http://<LOAD_BALANCER_IP>
}
```

Distribuciones como:

* 8 / 12
* 9 / 11
* 10 / 10
* 11 / 9

son completamente normales en un escenario 50/50.

No se espera necesariamente una distribución exacta de 10 y 10 en un conjunto pequeño de solicitudes.

---

# Seguridad implementada

* Las máquinas virtuales no poseen IP pública.
* El acceso a Internet se realiza mediante Cloud NAT.
* El firewall permite tráfico HTTP únicamente desde los rangos de Health Checks de Google Cloud.
* El usuario final solo conoce la IP pública del Load Balancer.
* La arquitectura cumple el requisito de aislamiento de fallos al mantener ambos servicios en instancias independientes.

---

# Consideraciones para un LLM

Para comprender el proyecto se recomienda seguir el siguiente orden:

1. Leer `variables.tf`.
2. Leer `terraform.tfvars`.
3. Revisar `network.tf`.
4. Revisar `nat.tf`.
5. Revisar `firewall.tf`.
6. Revisar `instances.tf`.
7. Revisar `load_balancer.tf`.
8. Revisar los scripts de `startup/`.
9. Consultar `README.md` para los escenarios de prueba.

---

# Comandos principales

Inicialización:

```bash
terraform init
```

Validación:

```bash
terraform fmt
terraform validate
terraform plan
```

Despliegue:

```bash
terraform apply
```

Destrucción:

```bash
terraform destroy
```

---

# Estado esperado del repositorio

El repositorio no debe incluir:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

El proyecto debe poder desplegarse desde cero ejecutando únicamente:

```bash
terraform apply
```

sin necesidad de realizar configuraciones manuales en la consola de Google Cloud.