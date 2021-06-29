#!/bin/sh
/usr/local/bin/codeql-runner-linux init --repository repository-name --github-url repository-url --github-auth-stdin GitHub-Apps-token-or-personal-access-token-from-stdin --languages java --queries security-extended
# 

# need to know how to replace this step
/usr/local/bin/codeql-runner-linux autobuild --tools-dir /home/codeql/codeql-runner-tools

/usr/local/bin/codeql-runner-linux analyze --commit commit-SHA --ref name-of-ref

/usr/local/bin/codeql-runner-linux upload --sarif-file file-or-directory