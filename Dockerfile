# Imagen oficial de Superset
FROM apache/superset:latest

# Trabajamos como root para instalar paquetes del sistema y pip
USER root

# --- Paquetes del sistema ---
# - default-libmysqlclient-dev + pkg-config: para mysqlclient
# - build-essential: necesario para compilar mysqlclient si hace falta
# (Para Postgres NO instalamos libpq-dev porque usamos psycopg2-binary)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# --- Drivers de BBDD vía pip ---
# Importante: usar psycopg2-binary (no mezclar con psycopg2)
RUN pip install --no-cache-dir \
    mysqlclient==2.2.4 \
    psycopg2-binary==2.9.9

# --- Variables de entorno que ya usabas ---
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}
ENV SECRET_KEY=${SECRET_KEY}

# --- Configuración e init de Superset ---
# La imagen base define WORKDIR=/app, así que copiamos ahí
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Volvemos al usuario no-root que usa Superset
USER superset

# Script de arranque (creación admin, init DB, etc.)
ENTRYPOINT ["/app/superset_init.sh"]
