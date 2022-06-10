# Base off the official python image
# Define a common stage for dev and prod images called base
FROM python:3.10 as base
# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
# Create a user to avoid running containers as root in production
RUN addgroup --system web \
    && adduser --system --ingroup web web
# Install os-level dependencies (as root)
RUN apt-get update && apt-get install -y -q --no-install-recommends \
  # dependencies for building Python packages
  build-essential \
  # postgress client (psycopg2) dependencies
  # libpq-dev \
  # cleaning up unused files to reduce the image size
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*
# Switch to the non-root user
USER web
# Create a directory for the source code and use it as base path
WORKDIR /home/web/code/
# Copy the python depencencies list for pip
COPY --chown=web:web ./requirements.txt requirements.txt
# Switch to the root user temporary, to grant execution permissions.
USER root
# Install python packages at system level
RUN pip install --no-cache-dir -r requirements.txt
# Copy entrypoint script which waits for the db to be ready
#COPY --chown=web:web ./docker/app/entrypoint.sh /usr/local/bin/entrypoint.sh
#RUN chmod +x /usr/local/bin/entrypoint.sh
# Copy the scripts that starts the default worker
# COPY --chown=web:web ./docker/app/start-celery-worker.sh /usr/local/bin/start-celery-worker.sh
# RUN chmod +x /usr/local/bin/start-celery-worker.sh
USER web
# This script will run before every command executed in the container
# ENTRYPOINT ["entrypoint.sh"]


# Define an image for local development. Inherits common packages from the base stage.
FROM base as dev
# The development server starts by default when the container starts
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080", "--reload"]


# Define an image for production. Inherits common packages from the base stage.
FROM base as prod
# The production server starts by default when the container starts
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
