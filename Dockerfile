FROM debian:trixie

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y tasksel && \
    tasksel install standard && \
    apt-get install -y supervisor openssh-server build-essential curl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/sshd /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@' /etc/pam.d/sshd

ENV UV_PYTHON=3.13 \
    UV_MANAGED_PYTHON=true \
    UV_TORCH_BACKEND=cu130
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    . $HOME/.local/bin/env && \
    uv python install && \
    mkdir vllm && cd vllm && \
    uv venv && \
    . .venv/bin/activate && \
    uv pip install vllm

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY --chmod=600 authorized_keys /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/bin/supervisord"]
