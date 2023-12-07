# ActiveState specific environment and functions.

# local
export INV_DB_URL=postgresql://pb_admin:2sPkz0bZKmlz83W9AdO8Cd0zV@localhost/inventory-api-v1

#alias bazel='bazelisk'
#alias minik='minikube kubectl --'
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/development
export KT_BROKERS_DEV=kafka-development.activestate.build:31090,kafka-development.activestate.build:31091,kafka-development.activestate.build:31092
export KT_BROKERS_PROD=kafka-production.activestate.build:31090,kafka-production.activestate.build:31091,kafka-production.activestate.build:31092
export KT_BROKERS="$KT_BROKERS_PROD"

# Try here. Delete if it becomes a problem.
export PATH=$HOME/code/activestate/TheHomeRepot/third_party/bin:$PATH

function install_state_tool() {
    sh <(curl -q https://platform.activestate.com/dl/cli/install.sh) -b beta --force
}

function thr() {
    #kperl
    export PATH=$PWD/third_party/bin:$PATH
}

function dashboard() {
    export PATH=$PWD/service/dashboard/node_modules/.bin:$PATH
}
