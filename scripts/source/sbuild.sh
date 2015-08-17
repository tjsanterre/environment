# Functions to initialize a C++ module that will build an
# executable with minimal user actions. This will use
# standalone SConstruct and SConscript files. It will
# not use sbuild to build.

function init_scons_c_module() {
    local module_name="$1"
    if [ -z "$module_name" ]; then
        echo 'Error: missing module name'
        return
    fi

    mkdir $module_name
    cd $module_name

    # Create the source direcory and main.cpp.
    mkdir src
    touch src/main.cpp

    # Create the sconstrut file.
    cat << EOF > sconstruct
env = Environment()
Export('env')

env.SConscript('sconscript', variant_dir='build', duplicate=0)

Clean('.', 'build')
EOF

    # Create the sconscript file.
    cat << EOF > sconscript
Import('env')

env.Append(CPPFLAGS=[
    '-std=c++11',
    '-Wall',
    '-Wextra',
    '-Wpedantic',
    '-Werror',
])

source_files = Glob('src/*.cpp', 'src/*.hpp')

env.Program(target='release/$module_name', source=source_files)
EOF
}
