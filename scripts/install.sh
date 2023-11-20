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
install_via_symlink gitconfig $HOME/.gitconfig

# Install vimrc. This includes setting up vundle.
install_via_symlink vimrc $HOME/.vimrc
if [[ ! -d $HOME/.vim/bundle ]]; then
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle.vim
fi

# Install useful tools.
