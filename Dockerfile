FROM perl:slim

RUN apt-get update && apt-get install -y \
    unzip \
    git \
 && rm -rf /var/lib/apt/lists/*

#Install all dependencies
RUN perl -MCPAN -e 'install Algorithm::Diff'
RUN perl -MCPAN -e 'install Regexp::Common'
RUN perl -MCPAN -e 'install Digest::MD5'
RUN perl -MCPAN -e 'install Parallel::ForkManager'

#Copy source code
COPY cloc /usr/src/
COPY .git /usr/src/.git
COPY tests /usr/src/tests
COPY Unix /usr/src/Unix

WORKDIR /usr/src/Unix

#Checkout of cloc_submodule_test for t/02_git.t tests
RUN git clone https://github.com/AlDanial/cloc_submodule_test.git

#Run tests
RUN make test

#Cleanup of git folder
RUN rm -rf .git