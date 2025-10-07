# Dockerfile
# Stage 1: Build
FROM hexpm/elixir:1.15.7-erlang-26.1.2-debian-bookworm-20231009-slim AS build

# Install build dependencies
RUN apt-get update -y && \
    apt-get install -y \
    build-essential \
    git \
    nodejs \
    npm \
    curl && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set working directory
WORKDIR /app

# Set build environment
ENV MIX_ENV=prod

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copy assets and compile
COPY assets assets
COPY priv priv

# Install npm dependencies and build assets
RUN cd assets && npm install && npm run deploy

# Compile project
COPY lib lib
COPY config config
RUN mix compile

# Compile assets
RUN mix assets.deploy

# Build release
RUN mix release

# Stage 2: Runtime
FROM debian:bookworm-20231009-slim AS app

# Install runtime dependencies
RUN apt-get update -y && \
    apt-get install -y \
    libstdc++6 \
    openssl \
    libncurses5 \
    locales \
    ca-certificates && \
    apt-get clean && \
    rm -f /var/lib/apt/lists/*_*

# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create app user
RUN useradd --create-home app
WORKDIR /home/app

# Copy release from build stage
COPY --from=build --chown=app:app /app/_build/prod/rel/stackoverflow_clone ./

USER app

# Expose port
EXPOSE 4000

# Set environment
ENV HOME=/home/app
ENV MIX_ENV=prod
ENV SECRET_KEY_BASE="your-secret-key-base-will-be-set-via-env"
ENV DATABASE_URL="ecto://postgres:postgres@db/stackoverflow_clone_prod"

# Start command
CMD ["bin/stackoverflow_clone", "start"]
