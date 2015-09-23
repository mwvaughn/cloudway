
warning () {

    _message=$1
    echo -e "\x1B[31mWarning: ${_message}\x1B[0m"
}

failure () {

    _message=$1
    echo -e "\x1B[3;41mFailure: ${_message}\x1B[0m"
    exit 1
}

success () {

    _message=$1
    echo -e "\x1B[32mSuccess: ${_message}\x1B[0m"
}

log () {

    _message=$1
    echo -e "\x1B[1m${_message}\x1B[0m"

}

CFN_CLI=$(which cfncluster)
if [[ -z "$CFN_CLI" ]];
then
    failure "Please install and configure \x1B[1mcfncluster\x1B[0m"
fi

# Test Agave API
AGAVE_CLI=$(which auth-check)
if [[ -z "$CFN_CLI" ]];
then
    failure "Please install and configure \x1B[1magave-clir\x1B[0m""
fi

auth-tokens-refresh -S