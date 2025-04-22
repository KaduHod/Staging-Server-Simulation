# Documentação do Servidor de Staging Ubuntu - Para simular meu servidor em produção

## Visão Geral

Este projeto configura um servidor de staging usando Docker com Ubuntu 24.04 como imagem base. O container inclui servidor SSH, Nginx e um usuário não-root com privilégios sudo para fins de implantação.

## Recursos

- Baseado no Ubuntu 24.04
- Servidor SSH configurado com autenticação por senha
- Servidor web Nginx pré-instalado
- Usuário dedicado `deployer` com permissões sudo limitadas
- Login root desativado para maior segurança
- Permissões adequadas configuradas para diretórios do Nginx

## Instruções de Uso

### Construindo a Imagem Docker

```bash
docker build -t kaduhod/ubuntu --build-arg ROOT_PASSWORD=123456 .
```

### Executando o Container

```bash
# Limpa entradas anteriores de known_hosts SSH
ssh-keygen -f "/home/carlos/.ssh/known_hosts" -R "172.17.0.2"

# Inicia o container
docker run -it --name homol-ubuntu kaduhod/ubuntu
```

### Acessando o Servidor

SSH para o container usando o usuário deployer:

```bash
ssh deployer@172.17.0.2
```

Senha: `123456`

## Detalhes do Dockerfile

```Dockerfile
FROM ubuntu:24.04

# Instala pacotes necessários
RUN apt-get update \
    && apt-get install -y iproute2 \
    openssh-server \
    openssh-client \
    sudo \
    nginx

# Cria usuário deployer com senha
RUN useradd -m -s /bin/bash deployer && \
    echo "deployer:123456" | chpasswd && \
    usermod -aG sudo deployer

# Configura servidor SSH
RUN mkdir -p /run/sshd && \
    chmod 0755 /run/sshd && \
    mkdir -p /var/run/sshd && \
    chmod 0755 /var/run/sshd

# Configura SSH para maior segurança
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configura permissões para Nginx
RUN mkdir -p /run/nginx && \
    chown -R deployer:www-data /run/nginx && \
    chown -R deployer:www-data /var/lib/nginx && \
    chown -R deployer:www-data /var/log/nginx && \
    chmod 775 -R /run/nginx /var/lib/nginx /var/log/nginx

# Adiciona permissões sudo específicas para o usuário deployer
RUN echo "deployer ALL=(root) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers && \
    echo "deployer ALL=(root) NOPASSWD: /bin/systemctl restart nginx" >> /etc/sudoers && \
    echo "deployer ALL=(root) NOPASSWD: /bin/systemctl reload nginx" >> /etc/sudoers

# Comando para iniciar o servidor SSH
CMD ["sh", "-c", "mkdir -p /run/sshd && /usr/sbin/sshd -D"]
```
