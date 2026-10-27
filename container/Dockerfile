# syntax=docker/dockerfile:1

# Image each SSH visitor is dropped into: every tool from the talk, plus a
# ready-made ~/playground. Build with container/ as the context (see server/setup-host.sh).
#
# Built in stages so compilers and build caches never reach the final image:
#   pokeget  compiles pokeget with the Rust toolchain; only the binary is kept
#   base     the runtime packages and zsh plugins
#   final    base + home files + the pokeget binary

# --- pokeget: build from source, keep only the binary -----------------------

FROM rust:1-slim AS pokeget
ARG POKEGET_VERSION=1.6.7
ENV CARGO_PROFILE_RELEASE_STRIP=true
RUN cargo install --locked --version "$POKEGET_VERSION" pokeget

# --- base: runtime packages --------------------------------------------------

FROM archlinux:latest AS base

RUN pacman -Syu --noconfirm --needed \
      bash zsh zsh-autosuggestions zsh-syntax-highlighting zsh-completions \
      git curl wget less vim neovim helix \
      tmux fzf zoxide bat eza fd ripgrep jq btop lazygit starship tree \
      procps-ng psmisc which libcap \
 && ln -s /usr/bin/helix /usr/local/bin/hx \
 && rm -rf /var/cache/pacman/pkg/*

# Containers run with --cap-drop ALL, and the kernel refuses to exec a binary
# whose file capabilities can't be granted (Arch ships btop with cap_perfmon,
# so it fails with "operation not permitted"). Strip them all; btop works fine
# without them.
RUN for f in $(getcap -r /usr 2>/dev/null | cut -d' ' -f1); do \
      setcap -r "$f"; \
    done \
 && test -z "$(getcap -r /usr 2>/dev/null)"

RUN useradd -m -s /bin/bash guest

# The rest of the zsh plugins, sourced directly by .zshrc (no plugin manager).
# Both are pinned, so these layers stay cached until a ref is bumped.
# fzf-tab isn't in the Arch repos; ADD fetches it at a tag.
ADD https://github.com/Aloxaf/fzf-tab.git#v1.2.0 /usr/share/zsh/plugins/fzf-tab

# Oh My Zsh plugins are single files, so fetch just those from a fixed commit.
ARG OMZ_REF=d2b7f557cceaddb16ba89bbf8200d8a8df35c4d8
ADD --chmod=644 \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OMZ_REF}/plugins/git/git.plugin.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OMZ_REF}/plugins/sudo/sudo.plugin.zsh \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/${OMZ_REF}/plugins/archlinux/archlinux.plugin.zsh \
    /usr/share/zsh/plugins/omz/

# --- final image -------------------------------------------------------------

FROM base

COPY --from=pokeget /usr/local/cargo/bin/pokeget /usr/local/bin/pokeget

COPY --chown=guest:guest home /home/guest/

USER guest
WORKDIR /home/guest
ENV LANG=C.UTF-8
# Build the completion dump now so the first login doesn't have to.
RUN zsh -fc 'autoload -Uz compinit && compinit -d ~/.zcompdump' \
 && sh setup-playground.sh

CMD ["bash", "-l"]
