FROM apache/superset:6.0.0

USER root

# Paquetes nativos (mysqlclient es opcional; quítalo si no lo usas)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# Instalar drivers en el venv de Superset usando uv
# (la imagen ya trae /app/.venv creado; no lo recrees)
RUN . /app/.venv/bin/activate && \
    uv pip install --upgrade \
      "psycopg[binary]==3.2.1" \
      "mysqlclient==2.2.4" && \
    python -c "import sys, psycopg; print('PY:', sys.executable); print('psycopg:', psycopg.__version__)"

# Config + init (igual que tenías)
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Variables (puedes dejarlas para sobreescribir desde Railway)
ENV SECRET_KEY=${SECRET_KEY}
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}

USER superset

ENTRYPOINT ["/app/superset_init.sh"]
