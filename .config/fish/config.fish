# ── config ─────────────────────────────────────────────────────

set fish_greeting ""

# ── paths ─────────────────────────────────────────────────────
fish_add_path $HOME/.local/bin
fish_add_path $HOME/Android/Sdk/cmdline-tools/latest/bin
fish_add_path $HOME/Android/Sdk/platform-tools

set -x ANDROID_HOME $HOME/Android/Sdk

# ── aliases ───────────────────────────────────────────────────
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias off='hyprshutdown --post-cmd poweroff'
alias reboot='hyprshutdown --post-cmd reboot'
alias logout='hyprctl dispatch exit'
alias remove-orphans='set orphans $(pacman -Qtdq); [ -n "$orphans" ] && sudo pacman -Rns $orphans || echo "No orphans found" | lolcat -a'
alias work='hyprctl dispatch exec "kitty --session ~/.config/kitty/sessions/work.session --directory $PWD"; exit'
alias lg='lazygit'

# ── nvm ───────────────────────────────────────────────────────
# fish no soporta nvm nativo, usar nvm.fish:
# fisher install jorgebucaran/nvm.fish
set -x NVM_DIR $HOME/.nvm

# ── starship prompt ───────────────────────────────────────────
starship init fish | source
alias hoy="zk hoy"
alias aprendi="zk aprendi"
alias proy="zk proy"
alias buscar="zk buscar"
set -x ZK_NOTEBOOK_DIR ~/notas
