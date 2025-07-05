FROM python:3.12-alpine

LABEL maintainer="gorgonaut"

ENV PYTHONUNBUFFERED=1 \
    POETRY_VERSION=2.1.1 \
    PATH="/root/.local/bin:$PATH"

WORKDIR /app

# Set build-time variable
ARG DEV=false
ENV DEV=$DEV

# Install system dependencies and poetry
RUN apk add --no-cache \ 
    python3-dev \
    libffi-dev \
    gcc \
    musl-dev \
    curl \
    postgresql-client && \
    apk add --no-cache --virtual .tmp-build-deps \
    build-base postgresql-dev && \
    pip install poetry==$POETRY_VERSION && \
    poetry config virtualenvs.create false

# Copy and install Python dependencies
COPY pyproject.toml poetry.lock ./
RUN if [ "$DEV" = "true" ]; then \
        poetry install --no-root; \
    else \
        poetry install --no-root --only main; \
    fi \
    && apk del .tmp-build-deps \
    && rm -rf /root/.cache /tmp/*

# Copy application code
COPY app/manage.py ./
COPY app/app ./app

# Create a user and switch to it
RUN adduser -D -H django-user && chown -R django-user /app
USER django-user

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]