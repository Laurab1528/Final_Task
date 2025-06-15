# Cloud & DevOps Final Project

## Overview
Este proyecto implementa una solución CI/CD modular y segura para desplegar una aplicación Python en AWS EKS usando Terraform, Helm y GitHub Actions. La arquitectura sigue buenas prácticas de seguridad y automatización.

---

## Arquitectura y Componentes Clave

- **VPC** y **subnet pública**: Ya existen y se referencian automáticamente en Terraform mediante data sources.
- **EC2 Runner**: Se crea manualmente en la subnet pública existente y se registra como self-hosted runner en GitHub Actions.
- **Subnets privadas, EKS, ALB, etc.**: Se crean automáticamente con Terraform en la misma VPC.
- **ALB**: Se crea en la subnet pública y enruta tráfico externo a los pods en subnets privadas.
- **GitHub Actions**: Pipelines CI/CD, usando el runner EC2 manual para despliegues privados.

---

## Flujo de Creación de Infraestructura

1. **VPC y subnet pública**: Ya existen y se referencian con data sources en Terraform.
2. **EC2 Runner**: Se lanza manualmente en la subnet pública y se registra en GitHub Actions.
3. **Subnets privadas, EKS, ALB, etc.**: Se crean con Terraform usando la VPC y subnet pública existentes.

---

## Resumen Visual

```mermaid
flowchart TD
    VPC[VPC existente]
    PUB[Subnet pública existente]
    PRIV[Subnets privadas (Terraform)]
    EKS[EKS (Terraform)]
    ALB[ALB (Terraform)]
    EC2[Runner EC2 (manual)]
    VPC --> PUB
    VPC --> PRIV
    VPC --> EKS
    VPC --> ALB
    PUB --> EC2
    EKS --> ALB
```

---

## Estructura del Repositorio

```
terraform/
  main.tf
  variables.tf
  outputs.tf
  providers.tf
  backend.tf
  modules/
    vpc/
    eks/
    alb/
  scripts/
    ensure-backend.sh
.github/
  workflows/
    infrastructure-pipeline.yml
    app-pipeline.yml
README.md
```

---

## Prerequisitos

- AWS CLI configurado
- Terraform >= 1.5.0
- Repositorio de GitHub con Actions y secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `API_KEY`, `PAT`)
- VPC y subnet pública ya creadas en AWS

---

## Setup y Despliegue

### 1. Bootstrap (PR)
- El workflow de infraestructura referencia la VPC y subnet pública existentes usando data sources.
- Los outputs (`vpc_id`, `public_subnet_ids`) quedan listos para la fase final.

### 2. Crear el runner EC2 manualmente
- Lanza una instancia EC2 en la subnet pública existente.
- Asigna el key pair y el security group adecuado (SSH abierto desde tu IP).
- Instala y registra el runner de GitHub Actions manualmente.

### 3. Fase final (merge a main)
- El workflow crea subnets privadas, EKS, ALB, etc., usando la VPC y subnet pública existentes.

---

## Pipelines

- **infrastructure-pipeline.yml:**
  - Bootstrap: Referencia VPC y subnet pública.
  - Full infra: Crea subnets privadas, EKS, ALB, etc.
- **app-pipeline.yml:**
  - Test/build en runners públicos.
  - Deploy en el runner EC2 manual.

---

## Buenas prácticas implementadas

- Código modular y reutilizable (módulos de VPC, EKS, ALB, etc.).
- Uso de data sources para recursos existentes.
- Outputs claros y documentados.
- Pipelines automáticos y seguros.
- Separación de fases (bootstrap y full infra).
- Documentación clara y diagrama de arquitectura.

---

## Pruebas y evidencia

- [ ] Captura de los recursos creados en AWS.
- [ ] Salida de `terraform output` mostrando los IDs usados.
- [ ] Screenshots del runner EC2 registrado y pipelines ejecutados.

---

## Notas adicionales

- El runner EC2 se crea y registra manualmente, no por Terraform.
- La VPC y la subnet pública ya existen y se referencian con data sources.
- Todos los recursos nuevos se crean en la misma VPC y subnets.
- El código es modular y fácil de mantener.

---

## License

MIT 