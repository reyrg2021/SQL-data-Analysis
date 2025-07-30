#!/bin/bash
# run-smart-sql.sh - Ejecutar SQL con detección automática de bases de datos
# Uso: ./run-smart-sql.sh archivo.sql
# Uso: ./run-smart-sql.sh carpeta/

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================================================
# FUNCIÓN PRINCIPAL
# ============================================================================

# Función para procesar un archivo SQL individual
process_sql_file() {
  local SCRIPT="$1"
  local FILE_NUM="$2"
  local TOTAL_FILES="$3"
  
  echo ""
  log "[$FILE_NUM/$TOTAL_FILES] Procesando: $(basename "$SCRIPT")"
  echo "=================================================="
  
  # Verificar que el archivo existe y es legible
  if [ ! -r "$SCRIPT" ]; then
    error "No se puede leer el archivo: $SCRIPT"
    return 1
  fi
  
  # Extraer el nombre de la base de datos del archivo (mejorado)
  DB_NAME=$(grep -i -E "(create database|create database if not exists)" "$SCRIPT" | head -n1 | sed -E 's/.*create[[:space:]]+database[[:space:]]+(if[[:space:]]+not[[:space:]]+exists[[:space:]]+)?([a-zA-Z0-9_-]+).*/\2/i' | tr -d ';' | xargs)

  if [ -n "$DB_NAME" ]; then
    log "Detectada base de datos: $DB_NAME"
    
    # Paso 1: Crear la base de datos
    log "Creando base de datos '$DB_NAME'..."
    
    # Extraer solo los comandos CREATE DATABASE y DROP DATABASE
    CREATE_DB_COMMANDS=$(grep -i -E "(drop database|create database)" "$SCRIPT" || true)
    
    if [ -n "$CREATE_DB_COMMANDS" ]; then
      if echo "$CREATE_DB_COMMANDS" | docker exec -i "$CONTAINER_ID" psql -U postgres -d postgres -v ON_ERROR_STOP=1; then
        log "Base de datos '$DB_NAME' creada exitosamente"
      else
        error "Error creando la base de datos '$DB_NAME'"
        return 1
      fi
    fi
    
    # Paso 2: Ejecutar el resto del script en la nueva base de datos
    log "Ejecutando script en la base de datos '$DB_NAME'..."
    
    # Crear un script temporal sin los comandos de creación de BD
    TEMP_SCRIPT="/tmp/temp_script_$(date +%s)_$(basename "$SCRIPT").sql"
    
    # Filtrar el archivo para quitar los comandos de BD pero mantener comentarios importantes
    {
      echo "-- Script procesado automáticamente desde: $SCRIPT"
      echo "-- Fecha: $(date)"
      echo "-- Base de datos destino: $DB_NAME"
      echo ""
      grep -v -i -E "(drop database|create database)" "$SCRIPT" || true
    } > "$TEMP_SCRIPT"
    
    # Verificar que el script temporal no esté vacío
    if [ ! -s "$TEMP_SCRIPT" ]; then
      warn "El script filtrado está vacío"
      rm -f "$TEMP_SCRIPT"
      return 1
    fi
    
    # Ejecutar con manejo de errores mejorado
    if docker exec -i "$CONTAINER_ID" psql -U postgres -d "$DB_NAME" -v ON_ERROR_STOP=1 -f - < "$TEMP_SCRIPT"; then
      log "Script ejecutado exitosamente en '$DB_NAME'"
      
      # Verificar que las tablas se crearon
      log "Verificando tablas creadas:"
      TABLES=$(docker exec "$CONTAINER_ID" psql -U postgres -d "$DB_NAME" -t -c "SELECT schemaname||'.'||tablename FROM pg_tables WHERE schemaname NOT IN ('information_schema', 'pg_catalog') ORDER BY schemaname, tablename;" 2>/dev/null || echo "")
      
      if [ -n "$TABLES" ]; then
        echo "$TABLES" | while read -r table; do
          [ -n "$table" ] && echo "   ✓ $table"
        done
      else
        warn "No se detectaron tablas creadas (puede ser normal si el script solo inserta datos)"
      fi
      
      # Mostrar información adicional
      log "Información de la base de datos:"
      docker exec "$CONTAINER_ID" psql -U postgres -d "$DB_NAME" -c "SELECT 
        (SELECT count(*) FROM information_schema.tables WHERE table_schema NOT IN ('information_schema', 'pg_catalog')) as tablas,
        (SELECT count(*) FROM information_schema.views WHERE table_schema NOT IN ('information_schema', 'pg_catalog')) as vistas;" 2>/dev/null || true
      
    else
      error "Error ejecutando el script en '$DB_NAME'"
      rm -f "$TEMP_SCRIPT"
      return 1
    fi
    
    # Limpiar archivo temporal
    rm -f "$TEMP_SCRIPT"
    
  else
    log "No detecté CREATE DATABASE, ejecutando en base 'postgres'..."
    
    if docker exec -i "$CONTAINER_ID" psql -U postgres -d postgres -v ON_ERROR_STOP=1 < "$SCRIPT"; then
      log "Script ejecutado exitosamente en base 'postgres'"
    else
      error "Error ejecutando el script en base 'postgres'"
      return 1
    fi
  fi
  
  return 0
}

# ============================================================================
# SCRIPT PRINCIPAL
# ============================================================================

INPUT="$1"

# Mostrar ayuda si no hay argumentos
if [ -z "$INPUT" ]; then
  echo ""
  echo " EJECUTOR INTELIGENTE DE SCRIPTS SQL"
  echo "======================================"
  echo ""
  echo "USO:"
  echo "   $0 <archivo.sql>     # Ejecutar archivo individual"
  echo "   $0 <carpeta/>        # Ejecutar todos los .sql de una carpeta"
  echo ""
  echo "CARACTERÍSTICAS:"
  echo "   • Detección automática de bases de datos en scripts"
  echo "   • Ejecución segura con manejo de errores"
  echo "   • Soporte para múltiples archivos en orden alfabético"
  echo "   • Verificación de resultados"
  echo ""
  echo "EJEMPLOS:"
  echo "   $0 mi-script.sql"
  echo "   $0 sql-scripts/"
  echo "   $0 manual-scripts/"
  echo ""
  exit 1
fi

# Verificar que el archivo o carpeta existe
if [ ! -e "$INPUT" ]; then
  error "El archivo o carpeta '$INPUT' no existe."
  exit 1
fi

# Detectar contenedor PostgreSQL
log "Buscando contenedor PostgreSQL..."

# Probar diferentes formas de encontrar el contenedor
CONTAINER_ID=""

# Método 1: docker-compose
if command -v docker-compose &> /dev/null; then
  CONTAINER_ID=$(docker-compose ps -q postgres 2>/dev/null || true)
fi

# Método 2: docker compose (nuevo)
if [ -z "$CONTAINER_ID" ] && command -v docker &> /dev/null; then
  CONTAINER_ID=$(docker compose ps -q postgres 2>/dev/null || true)
fi

# Método 3: buscar por nombre
if [ -z "$CONTAINER_ID" ]; then
  CONTAINER_ID=$(docker ps -q --filter "name=postgres" 2>/dev/null | head -n1 || true)
fi

# Método 4: buscar cualquier contenedor PostgreSQL
if [ -z "$CONTAINER_ID" ]; then
  CONTAINER_ID=$(docker ps -q --filter "ancestor=postgres" 2>/dev/null | head -n1 || true)
fi

if [ -z "$CONTAINER_ID" ]; then
  error "No se encontró ningún contenedor PostgreSQL en ejecución."
  echo ""
  echo "CONTENEDORES DISPONIBLES:"
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
  echo ""
  echo "SUGERENCIAS:"
  echo "1. Verifica que PostgreSQL esté corriendo: docker-compose up -d"
  echo "2. Verifica el nombre del servicio en docker-compose.yml"
  exit 1
fi

log "Contenedor PostgreSQL encontrado: ${CONTAINER_ID:0:12}..."

# Verificar que el contenedor responde
if ! docker exec "$CONTAINER_ID" pg_isready -U postgres >/dev/null 2>&1; then
  error "El contenedor PostgreSQL no responde"
  exit 1
fi

log "Conexión a PostgreSQL verificada ✓"

# Determinar si es archivo o carpeta
if [ -f "$INPUT" ]; then
  # Es un archivo individual
  log "Modo: Archivo individual"
  
  if ! process_sql_file "$INPUT" 1 1; then
    error "Error procesando el archivo"
    exit 1
  fi
  
elif [ -d "$INPUT" ]; then
  # Es una carpeta
  log "Modo: Carpeta completa"
  log "Carpeta: $INPUT"
  
  # Encontrar todos los archivos .sql en la carpeta
  SQL_FILES=($(find "$INPUT" -name "*.sql" -type f | sort))
  
  if [ ${#SQL_FILES[@]} -eq 0 ]; then
    warn "No se encontraron archivos .sql en '$INPUT'"
    exit 1
  fi
  
  log "Archivos SQL encontrados: ${#SQL_FILES[@]}"
  echo ""
  for i in "${!SQL_FILES[@]}"; do
    echo "   $((i + 1)). $(basename "${SQL_FILES[i]}")"
  done
  
  # Procesar cada archivo
  failed=0
  total=${#SQL_FILES[@]}
  successful=0
  
  for i in "${!SQL_FILES[@]}"; do
    file="${SQL_FILES[i]}"
    file_num=$((i + 1))
    
    if process_sql_file "$file" "$file_num" "$total"; then
      ((successful++))
    else
      error "Error en archivo: $(basename "$file")"
      ((failed++))
    fi
  done
  
  # Resumen final
  echo ""
  echo " RESUMEN DE EJECUCIÓN"
  echo "======================="
  echo -e "Total archivos: ${BLUE}$total${NC}"
  echo -e "Exitosos: ${GREEN}$successful${NC}"
  echo -e "Fallidos: ${RED}$failed${NC}"
  echo ""
  
  if [ $failed -eq 0 ]; then
    log "¡Todos los archivos se ejecutaron correctamente! 🎉"
  else
    error "Algunos archivos fallaron. Revisa los mensajes arriba."
    exit 1
  fi
  
else
  error "'$INPUT' no es un archivo ni una carpeta válida."
  exit 1
fi

# Mostrar bases de datos disponibles al final
echo ""
log "BASES DE DATOS DISPONIBLES:"
echo "============================"
docker exec "$CONTAINER_ID" psql -U postgres -c "\l" 2>/dev/null | grep -E "(Name|---|\|.*\|)" | head -20 || warn "No se pudieron listar las bases de datos"

log "Ejecución completada exitosamente ✓"