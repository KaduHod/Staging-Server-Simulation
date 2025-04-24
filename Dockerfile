FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y iproute2 \
    openssh-server \
    openssh-client \
    sudo \
    nginx \
    unzip \
    vim

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

COPY nginx/* /etc/nginx/sites-available/

EXPOSE 8080

CMD ["sh", "-c", "mkdir -p /run/sshd && /usr/sbin/sshd -D"]
