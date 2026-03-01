FROM ghcr.io/astral-sh/uv:python3.13-trixie-slim

# The steps should be ordered from less frequently changed to most
# To be able to split the cacheable layers and decrease build time

RUN apt-get update -q && \
	apt-get install -y -q --no-install-recommends \
	build-essential \
	python3-dev && \
	rm -rf /var/lib/apt/lists

WORKDIR /services/foo

ENV PYTHONPATH=/

COPY uv.lock uv.lock
COPY pyproject.toml pyproject.toml
RUN --mount=type=secret,id=gitlab_username,env=UV_INDEX_NEWSTORE_GITLAB_USERNAME \
	--mount=type=secret,id=gitlab_password,env=UV_INDEX_NEWSTORE_GITLAB_PASSWORD \
	uv sync --no-dev

COPY ./services/__init__.py /services/__init__.py
COPY ./services/foo/*.py /services/timer/
COPY ./services/foo/bar/ /services/foo/bar
RUN chmod +x /services/foo/bar/entrypoint.sh

EXPOSE 28200
EXPOSE 8000

ENTRYPOINT ["/services/timer/dispatcher/entrypoint.sh"]

