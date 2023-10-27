FROM python:3.10.4-bullseye

ENV POETRY_VERSION=1.6.0 POETRY_HOME=/poetry
ENV PATH=/poetry/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python3 -
WORKDIR /d3fau1t
COPY app/python/poetry.lock app/python/pyproject.toml ./
COPY app/python/redis-client ./redis-client
RUN poetry install --only main
