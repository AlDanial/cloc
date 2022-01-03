# Original Dockerfile by Sébastien HOUZÉ, https://github.com/shouze
# Adapted for use as devcontainer
FROM perl:slim AS base

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    unzip \
    locales \
    locales \
 && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8     

# Install all dependencies
RUN cpanm \
      Algorithm::Diff \
      Digest::MD5 \
      Parallel::ForkManager \
      Regexp::Common \
 && rm -rf $HOME/.cpanm
