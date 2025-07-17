# ActiveState specific environment and functions.

export AWS_PROFILE=sso

export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/development:$HOME/.kube/production
export KT_BROKERS_DEV=kafka-development.activestate.build:31090,kafka-development.activestate.build:31091,kafka-development.activestate.build:31092
export KT_BROKERS_PROD=kafka-production.activestate.build:31090,kafka-production.activestate.build:31091,kafka-production.activestate.build:31092
export KT_BROKERS="$KT_BROKERS_PROD"

#export USE_MYPY_DAEMON=true

alias pinv='psql -h pgdev.activestate.build -U pb_admin inventory_pr_prtemplate'


function inventory-benchmark-env() {
    local password=$(grep 'localhost:.*:pb_admin' $HOME/.pgpass | cut -d : -f 5)
    export INV_DB_URL="postgresql://pb_admin:${password}@localhost/inventory"
}

# Install state tool from release branch.
function st-install() {
    echo "installing state tool"
    sh <(curl -q https://platform.activestate.com/dl/cli/install.sh)
}

# Install state tool from beta branch.
function st-install-beta() {
    echo "installing state tool beta"
    sh <(curl -q https://platform.activestate.com/dl/cli/install.sh) -b beta --force
}

# Switch the environment the state tool is running against.
#
# Arguments:
# ENV - the environment to run state tool against such as: prod, prxxx, or staging
#
function st-env() {
    # Check for valid input first
    if [[ "$1" != 'prod' ]] && [[ "$1" != 'staging' ]] && [[ ! "$1" =~ ^pr[0-9]+$ ]]; then
        echo "Invalid or missing environment: ${1:-}"
        echo "Valid values are: prod, staging, or prNNN (where NNN is any number)"
        return 1
    fi

    echo "switching state env to $1"
    state auth logout
    pkill 'state-svc*'

    if [[ "$1" == 'prod' ]]; then
        unset ACTIVESTATE_API_HOST
        state auth --prompt
    else  # Will be either 'staging' or prXXXX
        export ACTIVESTATE_API_HOST="$1.activestate.build"
        state auth
    fi
}

# Report the state tool status.
function st-status() {
    if [[ -z "$ACTIVESTATE_ACTIVATED" ]]; then
        echo "Status: inactive"
    else
        local env=${ACTIVESTATE_API_HOST:-prod}
        echo "Status: activated"
        echo "Env: $env"
    fi
}

alias s="st-status"

# alias s='[[ -z ${ACTIVESTATE_ACTIVATED} ]] && echo "Not in an activated state" || echo "Activated: $ACTIVESTATE_ACTIVATED"'

function thr() {
    export PATH=$HOME/code/activestate/TheHomeRepot/third_party/bin:$PATH
}

# Try here. Delete if it becomes a problem.
thr

function dashboard() {
    export PATH=$PWD/service/dashboard/node_modules/.bin:$PATH
}

alias clean-test-dbs='/home/tyler/code/activestate/TheHomeRepot/extras/scripts/clean-test-dbs.sh'

#function clean-test-dbs() {
    #psql -l -X | grep -E '^.+-test-' | awk -F '|' '{ gsub(/ /, "", $1); print $1;  }' | xargs -t -n 1 dropdb
#}
