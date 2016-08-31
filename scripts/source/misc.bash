# Update LD_LIBRARY_PATH to include libs in the environment directory
function use_env_libs() {
    export LD_LIBRARY_PATH="$HOME/environment/lib:$LD_LIBRARY_PATH"
}

# Update package config search path to include environment directory
function use_env_pkgconfig() {
    export PKG_CONFIG_PATH="$HOME/environment/lib/pkgconfig:$PKG_CONFIG_PATH"
}

# Colorize man pages
function man() {
        #LESS_TERMCAP_md=$'\e[1;38;2;52;101;164m' \
        #LESS_TERMCAP_so=$'\e[1;40;92m' \
    env \
        LESS_TERMCAP_md=$'\e[1;34m' \
        LESS_TERMCAP_me=$'\e[0m' \
        LESS_TERMCAP_se=$'\e[0m' \
        LESS_TERMCAP_so=$'\e[0;33m' \
        LESS_TERMCAP_ue=$'\e[0m' \
        LESS_TERMCAP_us=$'\e[1;35m' \
        man "$@"
}
