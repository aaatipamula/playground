# Plugins are baked into the image (see container/Dockerfile)
ZSH_PLUGINS=/usr/share/zsh/plugins

# Oh My Zsh snippets: git, sudo, archlinux
for f in $ZSH_PLUGINS/omz/*.plugin.zsh; do source $f; done

# Load completion (zsh-completions is already on fpath via site-functions)
autoload -Uz compinit && compinit

# fzf-tab goes after compinit but before the widget-wrapping plugins below
source $ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh # Use fzf for tab completions

# Use history AND completions as suggestion source
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source $ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh

# Must be sourced last
source $ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completion styling
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-flags "$FZF_COLOR_OPTS" --bind=tab:accept
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Keybindings
bindkey -e  # Emacs keybinds
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# cd without typing 'cd'
setopt autocd

# VIM is my default editor
export VISUAL=vim
export EDITOR=vim

# Easy access/edit config files
alias zshrc="$EDITOR ~/.zshrc"
alias zshal="$EDITOR ~/.zsh_aliases"
alias zhist="$EDITOR ~/.zsh_history"
alias loadzsh="source $zshrc > /dev/null" # stdout > null to avoid startup display
alias dotfiles="cd $dotfiles"

# Aliases
alias ls="eza --icons=always"
alias tree="eza --icons=always -T"
alias ll="eza -l --git --smart-group --icons=always"
# alias ls="ls --color -h"
# alias ll="ls -l"      # Organize by date modified
alias l.="ls -d .*"     # Only hidden directory
alias lD="ls -Ud */"    # Only directories
alias la="ls -a"        # Everything including hidden files
alias p3="python3"      # Shortcut python3 bin
alias hist="history"    # Shortcut history
alias gd="git diff"     # Quick diff
alias gs="git status"   # Quick status
alias gl="git log"      # Quick log
alias tmn="tmux new-session -s" # tmux new session
alias tma="tmux attach-session -t"   # tmux attach to session
alias tmk="tmux kill-session -t "
alias httpserve="python3 -m http.server"

# Load fzf 
source <(fzf --zsh)

# Load zoxide (better cd)
eval "$(zoxide init zsh --cmd cd)"

# Load starship (prompt)
eval "$(starship init zsh)"

# History options
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

pokeget random
