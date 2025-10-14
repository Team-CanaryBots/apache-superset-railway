FROM apache/superset:latest

USER root

# Paquetes nativos que podrías necesitar (mysql opcional)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# Crear el venv si no existe e instalar drivers DENTRO del mismo
# Pasamos a psycopg3 para evitar el import de psycopg2
# -----------------------------------------------------------------------------
RUN if [ -x /app/.venv/bin/pip ]; then \
      echo "Using existing venv at /app/.venv"; \
    else \
      echo "Creating venv at /app/.venv"; \
      python -m venv /app/.venv && /app/.venv/bin/pip install --upgrade pip; \
    fi && \
    /app/.venv/bin/pip install --no-cache-dir \
      "psycopg[binary]==3.2.1" \
      mysqlclient==2.2.4 && \
    /app/.venv/bin/python -c "import sys, psycopg; print('PY:', sys.executable); print('psycopg:', psycopg.__version__)"

# Config + init
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Si defines variables aquí o en Railway, ambas valen:
ENV SECRET_KEY=${SECRET_KEY}
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}

USER superset

ENTRYPOINT ["/app/superset_init.sh"]
