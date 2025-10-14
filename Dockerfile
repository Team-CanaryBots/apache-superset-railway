# Base oficial de Superset (trae /app/.venv)
FROM apache/superset:latest

USER root

# Paquetes del sistema que puedas necesitar (mysql opcional)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# ⚠️ Instala en el VENV QUE USA SUPERSET
#     (fíjate en la ruta /app/.venv/bin/pip del log)
RUN /app/.venv/bin/pip install --no-cache-dir \
    psycopg2-binary==2.9.9 \
    mysqlclient==2.2.4

# Variables (puedes dejarlas en Railway si prefieres)
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}
ENV SECRET_KEY=${SECRET_KEY}

# Config + script de init
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Volver al usuario por defecto
USER superset

# Arranque
ENTRYPOINT ["/app/superset_init.sh"]
