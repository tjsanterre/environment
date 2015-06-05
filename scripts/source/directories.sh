
# change directory to a regular expression matching subdirectory
alias zi='zoomin'
function zoomin()
{
	local DIR="."
	test "$1" == "/" && DIR="/." && shift

	while test "$#" -gt 0; do
		DIR=$(_one_zoom "$DIR" "$1") || return 1
		shift
	done

	echo "$DIR"
	cd "$DIR"
}
function _one_zoom()
{
	local base="$1"
	local add="$2"
	if test -d "${base}/${add}"; then
		echo "${base}/${add}"
	else
		local next=$(_find_dir_named "$base" "$add")
		if test -n "$next"; then
			echo "${next}"
		else
			return 1
		fi
	fi
}
function _find_dir_named()
{
	local base="$1"
	local target="$2"
	local result=""

	for depth in 1 2 3 4; do
		result=$(find "$base" -mindepth $depth -maxdepth $depth -type d -iname "*$target*" | head -n 1)
		test "$result" && break
	done

	echo $result
}

# change directory to a matching parent directory
alias zo='zoomout'
function zoomout()
{
	local DIR="$(echo $PWD | grep -o ".*/[^/]*$1[^/]*/")"

	if test -z "$DIR"; then
		echo "No directory matching '$1'"
	else
		echo $DIR
		cd $DIR
	fi
}

# save the current directory to an alias name
alias m='mark'
function mark()
{
	test -z "$1" && return 1
	local DIR
	test -z "$2" && DIR="$PWD" || DIR="$2"
	echo $1=$DIR
	test -d ~/.marked_dirs || mkdir ~/.marked_dirs
	echo "$DIR" > ~/.marked_dirs/"$1"
}

# go to a marked directory
alias g='go_mark'
function go_mark()
{
	test -z "$1" && return 1
	test -f ~/.marked_dirs/"$1" || return 2
	local dir=$(cat ~/.marked_dirs/"$1")
	echo $dir
	cd "$dir"
}

# List all the marked directories
function list_marks()
{
	for f in ~/.marked_dirs/*; do
		echo "$(basename $f)=$(cat $f)"
	done
}

function drop_mark()
{
	local mark="$1"
	rm -f ~/.marked_dirs/"$mark"
}
