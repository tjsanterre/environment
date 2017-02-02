# Installs all scripts in this directory.

script_dir=$(cd "$(dirname "$0")"; pwd);
install_dir="${script_dir}/install"

function install_via_symlink() {
    ln -s -f $install_dir/link/$1 $2
}

install_via_symlink bashrc $HOME/.bashrc
install_via_symlink tmux.conf $HOME/.tmux.conf
install_via_symlink gitconfig $HOME/.gitconfig

# Install vimrc. This includes setting up vundle.
install_via_symlink vimrc $HOME/.vimrc
if [[ ! -d $HOME/.vim/bundle ]]; then
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle.vim
fi

# Install sbuild, customized scons build for c++.
mkdir -p $HOME/.scons/site_scons
install_via_symlink sbuild.py $HOME/.scons/site_scons/sbuild.py

