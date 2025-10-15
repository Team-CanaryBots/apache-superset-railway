FROM apache/superset:5.0.0

USER root

# Libs de sistema (mysqlclient es opcional; quítalo si no lo usas)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    default-libmysqlclient-dev \
  && rm -rf /var/lib/apt/lists/*

# Instala drivers dentro del venv de Superset
# Forzamos psycopg2-binary porque tu stack usa el dialecto psycopg2
RUN . /app/.venv/bin/activate && \
    python -m ensurepip --upgrade && \
    python -m pip install --no-cache-dir -U pip setuptools wheel && \
    python -m pip install --no-cache-dir \
      "psycopg2-binary==2.9.9" \
      "mysqlclient==2.2.4" && \
    python -c "import sys, psycopg2; print('PY:', sys.executable); print('psycopg2:', psycopg2.__version__)"

# Init + config (igual que tenías)
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Vars (puedes sobreescribirlas en Railway)
ENV SECRET_KEY=${SECRET_KEY}
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}

USER superset
ENTRYPOINT ["/app/superset_init.sh"]
