# Dockerfile by Sébastien HOUZÉ, https://github.com/shouze
FROM perl:slim AS base

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    unzip \
 && rm -rf /var/lib/apt/lists/*

#Install all dependencies
RUN cpanm \
      Algorithm::Diff \
      Digest::MD5 \
      Parallel::ForkManager \
      Regexp::Common \
 && rm -rf $HOME/.cpanm

#Copy source code
COPY cloc /usr/src/

####################
FROM base AS test

#Copy test code
COPY .git /usr/src/.git
COPY tests /usr/src/tests
COPY Unix /usr/src/Unix

WORKDIR /usr/src/Unix

#Checkout of cloc_submodule_test for t/02_git.t tests
RUN git clone https://github.com/AlDanial/cloc_submodule_test.git

#Run tests
RUN make test

####################
FROM base AS final

WORKDIR /tmp

ENTRYPOINT ["/usr/src/cloc"]
CMD ["--help"]
