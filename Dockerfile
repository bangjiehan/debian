FROM debian:trixie

RUN apt-get update && \
    apt-get install -y supervisor openssh-server && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chmod=600 authorized_keys /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/bin/supervisord"]
