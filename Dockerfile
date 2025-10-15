FROM apache/superset:2.0.0

USER root

# Libs de sistema (mysqlclient es opcional)
RUN apt-get update && apt-get install -y --no-install-recommends \
    pkg-config \
    default-libmysqlclient-dev \
    build-essential \
  && rm -rf /var/lib/apt/lists/*

# Instala drivers dentro del venv. Si hay 'uv', úsalo; si no, asegura pip y cae a pip.
RUN . /app/.venv/bin/activate && \
    python -m ensurepip --upgrade && \
    python -m pip install --no-cache-dir -U pip setuptools wheel || true && \
    (command -v uv >/dev/null 2>&1 || python -m pip install --no-cache-dir uv || true) && \
    (uv pip install --no-cache-dir "psycopg[binary]==3.2.1" "mysqlclient==2.2.4" \
     || python -m pip install --no-cache-dir "psycopg[binary]==3.2.1" "mysqlclient==2.2.4") && \
    python -c "import sys, psycopg; print('PY:', sys.executable); print('psycopg:', psycopg.__version__)"

# Tu init y config, igual que antes
COPY /config/superset_init.sh /app/superset_init.sh
RUN chmod +x /app/superset_init.sh
COPY /config/superset_config.py /app/superset_config.py
ENV SUPERSET_CONFIG_PATH=/app/superset_config.py

# Vars (si las sobreescribes en Railway, perfecto)
ENV SECRET_KEY=${SECRET_KEY}
ENV ADMIN_USERNAME=${ADMIN_USERNAME}
ENV ADMIN_EMAIL=${ADMIN_EMAIL}
ENV ADMIN_PASSWORD=${ADMIN_PASSWORD}
ENV DATABASE=${DATABASE}

USER superset
ENTRYPOINT ["/app/superset_init.sh"]
