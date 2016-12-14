# Installs all scripts in this directory.

script_dir=$(cd "$(dirname "$0")"; pwd);
install_dir="${script_dir}/install"

# Install bashrc.
ln -s -f $install_dir/link/bashrc $HOME/.bashrc

# Install vimrc. This includes setting up vundle.
ln -s -f $install_dir/link/vimrc $HOME/.vimrc
if [[ ! -d $HOME/.vim/colors ]]; then
    mkdir -p $HOME/.vim/colors
fi
ln -s -f $install_dir/link/zenburn.vim $HOME/.vim/colors/zenburn.vim

if [[ ! -d $HOME/.vim/bundle ]]; then
    mkdir -p $HOME/.vim/bundle
    git clone https://github.com/gmarik/Vundle.vim.git $HOME/.vim/bundle/vundle.vim
fi

# Install tmux.
ln -s -f $install_dir/link/tmux.conf $HOME/.tmux.conf

# Install sbuild, customized scons build for c++.
mkdir -p $HOME/.scons/site_scons
ln -s -f $install_dir/link/sbuild.py $HOME/.scons/site_scons/sbuild.py
