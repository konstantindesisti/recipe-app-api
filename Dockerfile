FROM python:3.10-alpine

LABEL maintainer="gorgonaut"

ENV PYTHONUNBUFFERED=1 \
    POETRY_VERSION=2.1.1 \
    PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY pyproject.toml poetry.lock ./
COPY app/manage.py ./
COPY app/app ./app

EXPOSE 8000

ARG DEV=false

RUN apk add --no-cache curl gcc musl-dev python3-dev libffi-dev && \
    pip install poetry==$POETRY_VERSION && \
    poetry config virtualenvs.create false && \
    if [ "$DEV" = "true" ]; then \
        poetry install --no-root; \
    else \
        poetry install --no-root --only main; \
    fi && \
    python -c "import django; print(django.__version__)" && \
    adduser -D -H django-user && \
    chown -R django-user /app


USER django-user
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]