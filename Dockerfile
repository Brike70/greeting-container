#
# Replace SHA with tag for better info on whats being pulled.
# Also use slimmer distro to save size.
# Also leaving Python version as is as that'll more likely be driven by dev team.
# FROM python:3.12@sha256:63828510c8b5ccce3bf0d6fabd6f3d17d4effa1ffe690f80a67c8e2d394e03ee
FROM python:3.12.15-slim-trixie

# Add env for reducing image size and allowing logs to go through docker logs
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

# Update OS in Image.
# Install just curl which we can use for the health checking.
# Remove uneeded Apt files to reduce image size.
RUN apt-get update \
 && apt-get full-upgrade -y \
 && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*

# Only pull the app through and not the whole repo
COPY ./app /app

WORKDIR /app

# Remove the extra /app since we've only pulled in the app folder.
RUN pip install -r requirements.txt

# Cleanup file
RUN rm /app/requirements.txt

EXPOSE 8080

# Tidy up run command now we've removed the extra /app/app folder
# Also add access logs for future use
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "--access-logfile", "-", "--error-logfile", "-", "app:app"]

# Add health check
HEALTHCHECK --interval=10s --timeout=3s --start-period=3s --retries=2 CMD [ "curl", "--fail", "http://127.0.0.1:8080/healthz" ]
