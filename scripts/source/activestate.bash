# ActiveState specific environment and functions.

#alias bazel='bazelisk'
#alias minik='minikube kubectl --'
export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/development
export KT_BROKERS_DEV=kafka-development.activestate.build:31090,kafka-development.activestate.build:31091,kafka-development.activestate.build:31092
export KT_BROKERS_PROD=kafka-production.activestate.build:31090,kafka-production.activestate.build:31091,kafka-production.activestate.build:31092
export KT_BROKERS="$KT_BROKERS_PROD"

# Try here. Delete if it becomes a problem.
export PATH=$HOME/code/activestate/TheHomeRepot/third_party/bin:$PATH

function inventory-benchmark-env() {
    password=$(grep 'localhost:.*:pb_admin' $HOME/.pgpass | cut -d : -f 5)
    export INV_DB_URL="postgresql://pb_admin:${password}@localhost/inventory-api-v1"
}

# Manage state tool working with PR environments. 
#
# Ags:
# command: status or start or stop
# pr_name: A PR name like pr12704, only need if command is start
function state-tool-pr() {
    usage="Usage: state_tool_pr_env status|start|stop [pr####] "

    if [[ -z "$1" || "$1" == "-h" || "$1" == "--help" ]]; then
        echo "$usage"
    elif [[ "$1" == "status" ]]; then
        if [[ -z "$ACTIVESTATE_API_HOST" ]]; then
            echo "status: inactive"
        else
            echo "status: ${ACTIVESTATE_API_HOST} active"
        fi
    elif [[ "$1" == "start" ]]; then
        if [[ ! "$2" =~ ^pr[0-9]+$ ]]; then
            echo "Invalid argument: $2, expected value matching pr#### format"
            echo "$usage"
        else
            export ACTIVESTATE_API_HOST="$2"
        fi
    elif [[ "$1" == "stop" ]]; then
        unset ACTIVESTATE_API_HOST
    else
        echo "Invalid argument: $1, expected 'start' or 'stop'"
        echo "$usage"
    fi
}

# Install state tool from beta branch.
function install-state-tool() {
    sh <(curl -q https://platform.activestate.com/dl/cli/install.sh) -b beta --force
}

function thr() {
    export PATH=$PWD/third_party/bin:$PATH
}

function dashboard() {
    export PATH=$PWD/service/dashboard/node_modules/.bin:$PATH
}
