FROM debian:stable-slim

# setup environment
ARG USER="runner"
ARG UID="100001"
ARG GID="101000"
ENV USER=${USER}
ENV HOME=/home/${USER}
ENV PATH="${HOME}/.nix-profile/bin:${PATH}"
ENV NIX_INSTALL_URL="https://install.determinate.systems/nix"

# install primary Debian packages
RUN apt update -y && \
    apt install -y curl git time sudo && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# create user and grant sudo privileges
RUN if ! getent group ${GID} > /dev/null 2>&1; then \
        groupadd --gid ${GID} ${USER}; \
    fi && \ 
    useradd --create-home --shell=/bin/bash --uid=${UID} --gid=${GID} ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/"${USER}"

# install nix for non-root user
USER ${USER}
WORKDIR ${HOME}
RUN curl --proto '=https' --tlsv1.2 -sSf \
    -L ${NIX_INSTALL_URL} | \
    sh -s -- install linux \
    --extra-conf "sandbox = false" \
    --extra-conf "filter-syscalls = false" \
    --extra-conf "trusted-users = root ${USER}" \
    --init none \
    --no-confirm

# set ownership for nix directory
USER root
RUN chown -R ${UID}:${GID} /nix

# revert to non-root user
USER ${USER}

# set Nix bin directory to PATH
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

ENTRYPOINT [ "/bin/bash" ]
