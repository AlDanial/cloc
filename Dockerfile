FROM perl:slim

RUN apt-get update && apt-get install -y \
    unzip \
    git \
 && rm -rf /var/lib/apt/lists/*

RUN perl -MCPAN -e 'install Algorithm::Diff'
RUN perl -MCPAN -e 'install Regexp::Common'
RUN perl -MCPAN -e 'install Digest::MD5'
RUN perl -MCPAN -e 'install Parallel::ForkManager'

COPY cloc /usr/src/
COPY .git /usr/src/.git
COPY tests /usr/src/tests
COPY Unix /usr/src/Unix

WORKDIR /usr/src/Unix

RUN make test
RUN rm -rf .git