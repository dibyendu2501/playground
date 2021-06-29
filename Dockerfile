FROM debian:buster-slim

ENV BUNDLE_VERSION=20210517 \
    USER=codeql \
    HOME=/home/codeql

RUN apt-get update && \
    apt-get install -y wget && \
    # Install codeql-runner as root
    wget --directory-prefix /usr/local/bin https://github.com/github/codeql-action/releases/download/codeql-bundle-$BUNDLE_VERSION/codeql-runner-linux && \
    chmod a+x /usr/local/bin/codeql-runner-linux && \
    # Add non-root user
    useradd --create-home --home-dir $HOME --uid 1000 --gid 0 $USER

USER 1000:0
WORKDIR $HOME

# Pre-install codeql-cli in the codeql home directory to save on download time
# Use `--tools-dir /home/codeql/codeql-runner-tools`
RUN wget https://github.com/github/codeql-action/releases/download/codeql-bundle-$BUNDLE_VERSION/codeql-bundle-linux64.tar.gz && \
    mkdir -p codeql-runner-tools/CodeQL/0.0.0-$BUNDLE_VERSION/x64 && \
    tar -xf codeql-bundle-linux64.tar.gz -C codeql-runner-tools/CodeQL/0.0.0-$BUNDLE_VERSION/x64 && \
    touch codeql-runner-tools/CodeQL/0.0.0-$BUNDLE_VERSION/x64.complete && \
    rm codeql-bundle-linux64.tar.gz

# ENTRYPOINT ["/usr/local/bin/codeql-runner-linux"]