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
BIN_DIR=$HOME/.local/bin
mkdir -p $BIN_DIR

# jq
if [[ ! -f $BIN_DIR/jq ]]; then
    echo 'installing latest jq'
    curl -sL -o $BIN_DIR/jq https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64
    chmod +x $BIN_DIR/jq
fi

# mob
if [[ ! -f $BIN_DIR/mob ]]; then
    curl -sL install.mob.sh | sh -s - --user
fi

# go tools
if command -v go 2>&1 >/dev/null; then
    # powerline
    if [[ ! -f $GOPATH/bin/powerline-go ]]; then
        echo "installing powerline-go to $GOPATH/bin"
        go install github.com/justjanne/powerline-go@latest
    fi

    # kt
    if [[ ! -f $GOPATH/bin/kt ]]; then
        echo "installing kt to $GOPATH/bin"
        go install github.com/fgeller/kt/v14@latest
    fi
else
    echo "go not installed; skipping go tools"
fi