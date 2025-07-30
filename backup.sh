#!/bin/bash
# backup.sh - Script de backup para todas las bases de datos
# Uso: ./backup.sh [--all] [--database nombre_bd]

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
CONTAINER_ID=$(docker-compose ps -q postgres 2>/dev/null)

if [ -z "$CONTAINER_ID" ]; then
    echo " No se encontró el contenedor postgres corriendo."
    exit 1
fi

# Crear directorio de backup si no existe
mkdir -p "$BACKUP_DIR"

backup_database() {
    local db_name=$1
    local backup_file="$BACKUP_DIR/${db_name}_backup_${TIMESTAMP}.sql"
    
    echo " Creando backup de: $db_name"
    
    if docker exec "$CONTAINER_ID" pg_dump -U postgres -d "$db_name" > "$backup_file"; then
        # Comprimir el backup
        gzip "$backup_file"
        echo " Backup creado: ${backup_file}.gz"
        
        # Mostrar tamaño del archivo
        local size=$(ls -lh "${backup_file}.gz" | awk '{print $5}')
        echo " Tamaño: $size"
    else
        echo " Error creando backup de $db_name"
        rm -f "$backup_file" 2>/dev/null || true
    fi
}

# Función para limpiar backups antiguos (mantener solo los últimos 10)
cleanup_old_backups() {
    echo " Limpiando backups antiguos..."
    find "$BACKUP_DIR" -name "*.sql.gz" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
    echo " Limpieza completada"
}

# Parsear argumentos
if [ "$1" = "--all" ] || [ $# -eq 0 ]; then
    echo " Iniciando backup de todas las bases de datos..."
    
    # Obtener lista de bases de datos (excluyendo las del sistema)
    databases=$(docker exec "$CONTAINER_ID" psql -U postgres -t -c "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname NOT IN ('postgres', 'template0', 'template1');" | sed 's/^ *//' | grep -v '^$')
    
    if [ -z "$databases" ]; then
        echo "  No se encontraron bases de datos de usuario para respaldar"
        echo " Respaldando base 'postgres' por defecto..."
        backup_database "postgres"
    else
        for db in $databases; do
            backup_database "$db"
        done
    fi
    
elif [ "$1" = "--database" ] && [ -n "$2" ]; then
    echo " Creando backup de base específica: $2"
    backup_database "$2"
    
else
    echo " Uso: $0 [--all] [--database nombre_bd]"
    exit 1
fi

cleanup_old_backups

echo ""
echo " Proceso de backup completado!"
echo " Ubicación: $BACKUP_DIR"
echo " Archivos creados:"
ls -la "$BACKUP_DIR"/*"$TIMESTAMP"* 2>/dev/null || echo "   (No se crearon archivos nuevos)"