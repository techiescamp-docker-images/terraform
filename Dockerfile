FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

WORKDIR /app

ARG TERRAFORM_VERSION=1.9.5
ARG TERRAFORM_DOCS_VERSION=0.18.0
ARG TFLINT_VERSION=0.53.0

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    unzip \
    curl \
    golang-go \
    python3-pip \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && wget https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz \
    && tar -xzf terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz \
    && mv terraform-docs /usr/local/bin/ \
    && rm terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-amd64.tar.gz \
    && wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip \
    && unzip tflint_linux_amd64.zip -d /usr/local/bin \
    && rm tflint_linux_amd64.zip \
    && pip3 install --no-cache-dir checkov \
    && go mod init terratest \
    && go get github.com/gruntwork-io/terratest/modules/terraform@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

CMD ["/bin/bash"]
