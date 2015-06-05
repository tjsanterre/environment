# Update LD_LIBRARY_PATH to include libs in the environment directory
function use_env_libs() {
    export LD_LIBRARY_PATH="$HOME/environment/lib:$LD_LIBRARY_PATH"
}

# Update package config search path to include environment directory
function use_env_pkgconfig() {
    export PKG_CONFIG_PATH="$HOME/environment/lib/pkgconfig:$PKG_CONFIG_PATH"
}
