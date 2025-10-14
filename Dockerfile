FROM apache/superset:latest
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
 && rm -rf /var/lib/apt/lists/*

# psycopg3 (binary) en el venv de Superset + verificación
RUN /app/.venv/bin/pip install --no-cache-dir --upgrade --force-reinstall \
      "psycopg[binary]==3.2.1" mysqlclient==2.2.4 \
 && /app/.venv/bin/python -c "import sys; print(sys.executable); import psycopg; print('psycopg3 OK', psycopg.__version__)"

COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh

COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

USER superset
ENTRYPOINT ["/app/superset_init.sh"]
