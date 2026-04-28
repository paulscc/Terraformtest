# Práctica de Terraform para AWS RDS PostgreSQL

Este proyecto crea una instancia de base de datos PostgreSQL en AWS RDS en la región `us-west-1` e incluye un script para verificar la conexión.

## Requisitos Previos

- Terraform instalado
- AWS CLI configurado con credenciales válidas
- Python 3.x instalado
- Cuenta de AWS con permisos para crear recursos RDS, VPC, Security Groups, etc.

## Archivos del Proyecto

- `main.tf` - Configuración principal de Terraform para crear RDS PostgreSQL
- `variables.tf` - Variables de configuración (nombre BD, usuario, contraseña)
- `outputs.tf` - Outputs que muestran la información de conexión
- `test_rds_connection.py` - Script Python para verificar la conexión a RDS PostgreSQL
- `requirements.txt` - Dependencias de Python (psycopg2-binary)
- `.github/workflows/deploy-rds.yml` - Workflow de GitHub Actions
- `terraform.tfvars.example` - Plantilla para variables sensibles
- `.gitignore` - Archivos ignorados por Git

## Instrucciones de Uso

### 1. Configurar Variables

Edita el archivo `terraform.tfvars` (o pasa las variables por línea de comandos) para definir tu contraseña:

```bash
# Opción 1: Crear archivo terraform.tfvars
db_password = "TuContraseñaSegura123"
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Planificar los Cambios

```bash
terraform plan -var="db_password=TuContraseñaSegura123"
```

### 4. Aplicar la Configuración

```bash
terraform apply -var="db_password=TuContraseñaSegura123"
```

Confirma con `yes` cuando se te solicite.

**Nota:** La creación de la instancia RDS puede tardar entre 10-15 minutos.

### 5. Obtener Información de Conexión

Después de que Terraform termine, verás los outputs con:
- Endpoint de RDS
- Usuario
- Nombre de la base de datos

También puedes ver los outputs en cualquier momento:

```bash
terraform output
```

### 6. Verificar la Conexión

Instala las dependencias de Python:

```bash
pip install -r requirements.txt
```

Ejecuta el script de prueba:

```bash
python test_rds_connection.py
```

El script te pedirá:
- Endpoint de RDS (copia del output de Terraform)
- Usuario (default: admin)
- Contraseña
- Nombre de la base de datos (default: testdb)
- Puerto (default: 3306)

El script intentará conectarse con reintentos automáticos (espera necesario ya que RDS puede tardar unos minutos en estar completamente disponible).

### 7. Limpiar Recursos

Cuando termines la práctica, elimina los recursos para evitar costos:

```bash
terraform destroy -var="db_password=TuContraseñaSegura123"
```

## Uso con GitHub Actions

Este proyecto incluye un workflow de GitHub Actions que automatiza el despliegue de RDS y la prueba de conexión.

### Configuración de Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Navega a **Settings** > **Secrets and variables** > **Actions**
3. Agrega los siguientes secrets:

   - `AWS_ACCESS_KEY_ID` - Tu AWS Access Key ID
   - `AWS_SECRET_ACCESS_KEY` - Tu AWS Secret Access Key
   - `DB_PASSWORD` - Contraseña para la base de datos RDS

### Ejecutar el Workflow

El workflow se ejecuta automáticamente en:
- Push a la rama `main`
- Pull requests a la rama `main`
- Manualmente desde la pestaña **Actions** (workflow_dispatch)

### Pasos del Workflow

1. **Checkout** - Obtiene el código del repositorio
2. **Configure AWS credentials** - Configura credenciales de AWS
3. **Terraform Init** - Inicializa Terraform
4. **Terraform Format Check** - Verifica formato del código
5. **Terraform Plan** - Genera plan de ejecución
6. **Terraform Apply** - Aplica la configuración y crea RDS
7. **Get RDS Endpoint** - Obtiene el endpoint de RDS desde outputs
8. **Setup Python** - Configura Python 3.11
9. **Install dependencies** - Instala pymysql
10. **Wait for RDS** - Espera 5 minutos para que RDS esté disponible
11. **Test RDS Connection** - Prueba la conexión a la base de datos
12. **Terraform Destroy** - (Opcional) Destruye recursos después de la prueba

**Nota:** El paso `Terraform Destroy` está configurado para ejecutarse siempre (`if: always()`). Si quieres mantener los recursos, comenta o elimina ese paso en el archivo `.github/workflows/deploy-rds.yml`.

### Modo Interactivo vs No Interactivo

El script `test_rds_connection.py` soporta dos modos:

- **Modo interactivo** (local): Solicita datos por terminal
- **Modo no interactivo** (GitHub Actions): Recibe argumentos por línea de comandos

Ejemplo de uso local con argumentos:
```bash
python test_rds_connection.py \
  --host "postgresql-instance.xxxx.us-west-1.rds.amazonaws.com" \
  --username "admin" \
  --password "TuContraseña" \
  --database "testdb" \
  --port 5432
```

## Recursos Creados

- VPC (10.0.0.0/16)
- Internet Gateway
- Route Table
- 2 Subnets (us-west-1a, us-west-1b)
- Security Group para RDS (permite puerto 5432)
- DB Subnet Group
- Instancia RDS PostgreSQL 15.4 (db.t3.micro, 20GB)

## Costos Estimados

- Instancia RDS db.t3.micro: ~$15-20/mes
- Almacenamiento 20GB GP2: ~$2/mes
- **Importante:** Recuerda destruir los recursos cuando termines para evitar cargos inesperados.

## Solución de Problemas

### Error de conexión
- Verifica que el Security Group permite tu IP
- Espera unos minutos después de la creación de RDS
- Confirma que la instancia esté en estado "available" en la consola de AWS

### Error de permisos
- Asegúrate de que tus credenciales de AWS tengan los permisos necesarios
- Verifica que AWS CLI esté configurado correctamente: `aws sts get-caller-identity`
