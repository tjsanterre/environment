# Installs all scripts in this directory.

script_dir=$(cd "$(dirname "$0")"; pwd);
install_dir="${script_dir}/install"

function install_via_symlink() {
    local parent_dir=$(dirname $2)
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi
    ln -s -f $install_dir/link/$1 $2
}


# Install all files that only require symlink.
install_via_symlink bashrc $HOME/.bashrc
install_via_symlink bash_aliases $HOME/.bash_aliases
install_via_symlink bash_prompt $HOME/.bash_prompt
install_via_symlink tmux.conf $HOME/.tmux.conf
install_via_symlink gitconfig $HOME/.gitconfig


# Install vscode user settings.
if [[ -d $HOME/.config/Code/User ]]; then
    mkdir -p $HOME/.config/Code/User
fi
install_via_symlink vscode_settings.json $HOME/.config/Code/User/settings.json


# Install vimrc. This includes setting up vundle.
install_via_symlink vimrc $HOME/.vimrc
if [[ ! -d $HOME/.vim/bundle ]]; then
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle.vim
fi


# Install neovim
install_via_symlink init.nvim $XDG_CONFIG_HOME/nvim/init.vim
if [[ ! -f $XDG_DATA_HOME/nvim/site/autoload/plug.vim ]]; then
    curl -fLo $XDG_DATA_HOME/nvim/site/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi


# Install sbuild, customized scons build for c++.
mkdir -p $HOME/.scons/site_scons
install_via_symlink sbuild.py $HOME/.scons/site_scons/sbuild.py

