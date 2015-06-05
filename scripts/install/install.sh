# Installs all scripts in this directory.

install_dir=$(cd "$(dirname "$0")"; pwd);

# Link the scripts in the link directory.
ln -s $install_dir/link/bashrc $HOME/.bashrc
