FROM ubuntu:20.04

RUN apt-get update \
    && apt-get install -y wget unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://releases.hashicorp.com/terraform/1.5.5/terraform_1.5.5_linux_amd64.zip \
    && unzip terraform_1.5.5_linux_amd64.zip \
    && mv terraform /usr/local/bin/ \
    && rm terraform_1.5.5_linux_amd64.zip

WORKDIR /app

EXPOSE 80
