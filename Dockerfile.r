FROM rocker/verse:latest

ENV TZ Asia/Tokyo
ARG UID
ARG GID
ARG PROJECT
ARG USERNAME=rstudio

RUN apt-get update && apt-get install -y curl git sudo tmux ripgrep \
    language-pack-ja-base language-pack-ja make gcc nodejs npm && \
    # nvim install 
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x nvim.appimage && \
    ./nvim.appimage --appimage-extract && \
    ./squashfs-root/AppRun --version && \
    ln -s /squashfs-root/AppRun /usr/bin/nvim && \
    rm nvim.appimage 

# update nodejs for copilot 
RUN npm install n -g && \
    n stable && \
    apt-get purge -y nodejs npm && \
    apt-get autoremove -y

# setup neovim
COPY --chown=${USERNAME} dotfiles/.config/ /home/${USERNAME}/.config/
COPY --chown=${USERNAME} dotfiles/.tmux.conf /home/${USERNAME}/.tmux.conf
COPY --chown=${USERNAME} dotfiles/.scripts /home/${USERNAME}/.scripts
RUN echo "alias ide='sh ~/.scripts/ide.sh'" >> /home/${USERNAME}/.bashrc && \
    echo "alias apply_nvim='sh ~/.scripts/apply.sh --R'" >> /home/${USERNAME}/.bashrc && \
    echo "alias tmux='tmux -u'" >> /home/${USERNAME}/.bashrc 
USER ${USERNAME}
WORKDIR /workspaces/${PROJECT}/

RUN nvim --headless "+Lazy! sync" +qa
