#!/bin/bash
# setup.sh - Configuración completa y robusta de entorno Data Science

set -e  # Salir si hay errores

echo " Configurando entorno de bases de datos..."

# ============================================================================
# VERIFICACIONES PREVIAS
# ============================================================================

echo " Verificando dependencias..."

# Verificar que Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo " Error: Docker no está corriendo. Inicia Docker primero."
    exit 1
fi 

# Verificar que existe docker-compose.yml
if [ ! -f "docker-compose.yml" ]; then
    echo " Error: No se encontró docker-compose.yml"
    exit 1
fi

echo " Dependencias verificadas"

# ============================================================================
# CONFIGURACIÓN DE ARCHIVOS
# ============================================================================

# Verificar que existe archivo .env
if [ ! -f ".env" ]; then
    echo "  Advertencia: No se encontró archivo .env"
    echo " Creando archivo .env básico..."
    cat > .env << EOF
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_123
POSTGRES_DB=postgres
POSTGRES_PORT=5432
POSTGRES_SHARED_BUFFERS=256MB
POSTGRES_EFFECTIVE_CACHE_SIZE=1GB
EOF
    echo " Archivo .env creado"
fi

# ============================================================================
# LIMPIEZA Y CONFIGURACIÓN DE DOCKER (MEJORADO)
# ============================================================================

echo " Configurando servicios Docker..."

# SIEMPRE hacer limpieza completa para evitar problemas
echo "🧹 Limpiando contenedores y volúmenes anteriores..."
docker-compose down -v 2>/dev/null || true

# Eliminar contenedores huérfanos
docker-compose rm -f 2>/dev/null || true

# Limpiar volúmenes específicos del proyecto
docker volume ls -q | grep -E "(postgres|proyecto)" | xargs -r docker volume rm 2>/dev/null || true

echo " Iniciando servicios..."
docker-compose up -d

# ============================================================================
# VERIFICACIÓN MEJORADA DE POSTGRESQL
# ============================================================================

# Función mejorada para verificar PostgreSQL
wait_for_postgres() {
    echo " Esperando a que PostgreSQL esté completamente listo..."
    
    local max_attempts=60  # Aumentado a 60 (2 minutos)
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        # Verificar que el contenedor existe y está corriendo
        if ! docker-compose ps postgres | grep -q "Up"; then
            echo " Intento $attempt/$max_attempts - Contenedor iniciando..."
            sleep 2
            ((attempt++))
            continue
        fi
        
        # Verificar que PostgreSQL responde
        if docker-compose exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
            echo " PostgreSQL responde, verificando autenticación..."
            
            # Verificar que podemos conectarnos realmente
            if docker-compose exec -T postgres psql -U postgres -d postgres -c "SELECT 1;" > /dev/null 2>&1; then
                echo " PostgreSQL está completamente listo!"
                return 0
            else
                echo "  PostgreSQL responde pero no permite conexiones aún..."
            fi
        fi
        
        echo " Intento $attempt/$max_attempts - Esperando PostgreSQL..."
        sleep 2
        ((attempt++))
    done
    
    echo " Error: PostgreSQL no respondió después de $max_attempts intentos"
    echo " Información de diagnóstico:"
    docker-compose ps
    docker-compose logs postgres | tail -10
    return 1
}

# Esperar a que PostgreSQL esté listo
if wait_for_postgres; then
    # Verificación adicional
    echo " Verificando conexiones y configuración..."
    
    # Mostrar información del contenedor
    echo " Estado del contenedor:"
    docker-compose ps postgres
    
    # Verificar variables de entorno
    echo " Variables de autenticación:"
    docker-compose exec postgres env | grep POSTGRES | sort
    
    # Probar conexión completa
    echo " Probando conexión completa..."
    if docker-compose exec postgres psql -U postgres -c "\l" > /dev/null 2>&1; then
        echo " Conexión verificada exitosamente"
        
        # Mostrar bases de datos disponibles
        echo " Bases de datos disponibles:"
        docker-compose exec postgres psql -U postgres -c "\l"
    else
        echo " Error en la verificación de conexión"
        exit 1
    fi
    
    echo ""
    echo " ¡Entorno completamente configurado!"
    echo ""
    echo " INFORMACIÓN DE CONEXIÓN:"
    echo "    PostgreSQL desde DBeaver:"
    echo "      Host: localhost"
    echo "      Port: 5432"
    echo "      Database: postgres"
    echo "      User: postgres"
    echo "      Password: secure_password_123"
    echo ""
    echo " COMANDOS ÚTILES:"
    echo "    Ver logs: docker-compose logs -f postgres"
    echo "    Reiniciar: docker-compose restart postgres"
    echo "    Parar: docker-compose down"
    echo "    Reset completo: docker-compose down -v"
    echo ""
    echo " PARA EMPEZAR:"
    echo "   1. Abrir DBeaver"
    echo "   2. Conectar con los datos de arriba"
    echo "   3. Crear tu base de datos para la prueba"
    echo "   4. ¡Comenzar a trabajar!"
    
else
    echo " Error: No se pudo configurar PostgreSQL correctamente"
    echo " Intenta ejecutar el script nuevamente o revisa los logs"
    exit 1
fi