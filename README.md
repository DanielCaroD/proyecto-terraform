# Taller GCP - Balanceo de Tráfico con Terraform

## Descripción

Este proyecto implementa una infraestructura en Google Cloud Platform (GCP) completamente automatizada mediante Terraform, cuyo objetivo es desplegar un sistema de balanceo de carga con dos servicios independientes:

* **Servicio Principal (Producción)**: muestra el mensaje:

  > Bienvenido al Servicio Principal - Version Produccion

* **Servicio de Contingencia (Mantenimiento)**: muestra el mensaje:

  > Error 503 – Sitio en Mantenimiento Programado

La solución permite modificar la distribución del tráfico entre ambos servicios únicamente cambiando variables de Terraform, sin necesidad de modificar la infraestructura manualmente desde la consola de GCP.

---

# Arquitectura

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

* VPC personalizada.
* Dos máquinas virtuales independientes.
* Balanceador HTTP externo.
* Health Checks automáticos.
* Máquinas virtuales sin IP pública.
* Salida a Internet mediante Cloud NAT.
* Infraestructura completamente definida como código (IaC).

---

# Requisitos

* Terraform >= 1.5
* Cuenta de Google Cloud Platform.
* Google Cloud CLI (`gcloud`) autenticado.
* APIs de Compute Engine habilitadas.

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

* Todas las solicitudes llegan al servicio de producción.

---

## Escenario 2 – Mantenimiento Total

```hcl
prod_weight        = 0
maintenance_weight = 100
```

Resultado esperado:

* Todas las solicitudes muestran la página de mantenimiento.

---

## Escenario 3 – Balance Equitativo

```hcl
prod_weight        = 50
maintenance_weight = 50
```

Resultado esperado:

* El tráfico se distribuye entre ambos servicios.

Debido al comportamiento de caché y reutilización de conexiones HTTP de los navegadores modernos, la validación del balanceo se realizó mediante múltiples conexiones independientes utilizando:

```powershell
1..20 | % {
    Start-Sleep -Milliseconds 500
    curl.exe http://<LOAD_BALANCER_IP>
}
```

---

# Despliegue

Inicializar Terraform:

```bash
terraform init
```

Verificar configuración:

```bash
terraform validate
terraform fmt
terraform plan
```

Desplegar infraestructura:

```bash
terraform apply
```

---

# Destrucción de la infraestructura

Para evitar consumo innecesario de créditos de GCP:

```bash
terraform destroy
```

---

# Recursos desplegados

* VPC personalizada.
* Subred privada.
* Reglas de firewall.
* Cloud Router.
* Cloud NAT.
* Dos instancias Compute Engine.
* Instance Groups.
* Health Checks.
* HTTP Load Balancer.
* Dirección IP pública global.

---

# Seguridad implementada

* Las máquinas virtuales no poseen direcciones IP públicas.
* El acceso a Internet se realiza mediante Cloud NAT.
* El firewall únicamente permite tráfico HTTP proveniente de los Health Checks de Google Cloud.
* Los usuarios externos solo conocen la IP pública del Load Balancer.

---

# Evidencias

Agregar en esta sección las capturas de:

1. Balanceador funcionando.
2. Backends saludables.
3. Máquinas virtuales sin IP pública.
4. Pruebas de los tres escenarios.
5. Ejecución exitosa de `terraform destroy`.
