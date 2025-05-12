FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y iproute2 \
    openssh-server \
    openssh-client \
    sudo \
    nginx \
    unzip \
    vim \
    curl \
    ca-certificates

RUN useradd -m -s /bin/bash deployer && \
    echo "deployer:123456" | chpasswd && \
    usermod -aG sudo deployer

RUN mkdir -p /run/sshd && \
    chmod 0755 /run/sshd && \
    mkdir -p /var/run/sshd && \
    chmod 0755 /var/run/sshd

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN mkdir -p /var/www/html/meu-site
RUN mkdir -p /run/nginx && \
    chown -R deployer:www-data /run/nginx && \
    chown -R deployer:www-data /var/lib/nginx && \
    chown -R deployer:www-data /var/log/nginx && \
    chmod 775 -R /run/nginx /var/lib/nginx /var/log/nginx /var/www/html/meu-site

RUN chown -R deployer:www-data /var/www/html/meu-site

RUN echo "deployer ALL=(root) NOPASSWD: /usr/sbin/nginx" >> /etc/sudoers && \
    echo "deployer ALL=(root) NOPASSWD: /bin/systemctl restart nginx" >> /etc/sudoers && \
    echo "deployer ALL=(root) NOPASSWD: /bin/systemctl reload nginx" >> /etc/sudoers
RUN usermod -aG www-data deployer

# Docker
RUN install -m 0755 -d /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
RUN chmod a+r /etc/apt/keyrings/docker.asc
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Copy Nginx configuration files
COPY nginx/* /etc/nginx/sites-available/

# Create symbolic links for all available sites
RUN for file in /etc/nginx/sites-available/*; do \
      ln -s "$file" "/etc/nginx/sites-enabled/$(basename "$file")"; \
    done
RUN mkdir -p /home/deployer/.ssh && \
    chmod 700 /home/deployer/.ssh
# Copie sua chave pública para o arquivo authorized_keys
RUN ls -lah
COPY id_rsa.pub /home/deployer/.ssh/authorized_keys

RUN chmod 600 /home/deployer/.ssh/authorized_keys && \
    chown -R deployer:deployer /home/deployer/.ssh

RUN wget https://go.dev/dl/go1.24.3.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.24.3.linux-amd64.tar.gz
RUN export PATH=$PATH:/usr/local/go/bin
ENV PATH="/usr/local/go/bin:${PATH}"
RUN echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/deployer/.bashrc

EXPOSE 8080 3000 3001 3002 3003 3004 3005 3006

CMD ["sh", "-c", "mkdir -p /run/sshd && /usr/sbin/sshd -D"]
