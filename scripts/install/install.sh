# Installs all scripts in this directory.

install_dir=$(cd "$(dirname "$0")"; pwd);

# Install bashrc.
ln -s -f $install_dir/link/bashrc $HOME/.bashrc

# Install vimrc. This includes setting up vundle.
ln -s -f $install_dir/link/vimrc $HOME/.vimrc
if [[ ! -d $HOME/.vim/colors ]]; then
    mkdir -p $HOME/.vim/colors
    ln -s $install_dir/link/zenburn.vim $HOME/.vim/colors/zenburn.vim
fi
if [[ ! -d $HOME/.vim/bundle ]]; then
    mkdir -p $HOME/.vim/bundle
    git clone http://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle.vim
fi
