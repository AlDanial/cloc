# Dockerfile by Sébastien HOUZÉ, https://github.com/shouze
FROM perl:slim AS builder

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    dos2unix \
    gcc

#Install all dependencies
RUN cpanm \
      Algorithm::Diff \
      Digest::MD5 \
      Parallel::ForkManager \
      Regexp::Common

#Copy source code
COPY cloc /usr/src/
RUN find /usr/src/ -type f -exec dos2unix {} \;

FROM perl:slim AS base

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    git \
    unzip \
 && rm -rf /var/lib/apt/lists/*

#Copy dependencies and source prepared in base image
COPY --from=builder /usr/local/lib/perl5 /usr/local/lib/perl5
COPY --from=builder /usr/src/ /usr/src/

####################
FROM base AS test

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates

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

#Only add this comment file
