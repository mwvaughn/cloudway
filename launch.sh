#!/bin/bash

# Imported from Global
CFN_NAME=${CLUSTER_NAME:=democluster}
CFN_CONFIG=${CLUSTER_CONFIG:=demo.cfn}
CFN_PEM=${CLUSTER_PEM:=demo.pem}
CFN_USER=$(CLUSTER_USER:=ec2-user}

# no default values
IPLANT_USERNAME=$IPLANT_USERNAME
AWS_IAM_KEY=$AWS_IAM_KEY
AWS_IAM_SECRET=$AWS_IAM_SECRET

#Shared globals
PUBLIC_IP=''
MASTER=''
SERIALIZED_PRIVATE=''
SERIALIZED_PUBLIC=''
EXECSYSTEM=''
DATE=`date +%Y-%m-%d`
CFN_NAME="${CFN_NAME}-$DATE"

FDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $FDIR/lib/common.sh

cluster_create() {
    log "Creating cluster... may take some time"
    cfncluster_create=$(cfncluster --config "configs/${CFN_CONFIG}" create ${CFN_NAME})
}

cluster_get_status() {

    log "Getting status and IP address..."
    cfncluster_status=$(cfncluster status ${CFN_NAME})
    PUBLIC_IP=$(echo $cfncluster_status | egrep -o -e "MasterPublicIP\"=\"[0-9\.]+\"" | egrep -o -e "[0-9\.]+")
    MASTER=$(cfncluster instances ${CFN_NAME} | grep "MasterServer" | awk '{print $2}')
    echo "Instance ${MASTER} @ ${PUBLIC_IP}"
}

cluster_get_keys() {

    # Copy the keys from Master
    log "Getting SSH keys..."
    scp -q -i pems/$CFN_PEM ec2-user@${PUBLIC_IP}:.ssh/id_rsa.pub .
    scp -q -i pems/$CFN_PEM ec2-user@${PUBLIC_IP}:.ssh/id_rsa .
    SERIALIZED_PRIVATE=$(jsonpki.sh --private id_rsa  | sed 's|\\|\\\\|g' )
    SERIALIZED_PUBLIC=$(jsonpki.sh --public id_rsa.pub)
    rm -rf id_rsa.pub id_rsa
    log "Public: ${SERIALIZED_PUBLIC}"


}

cluster_login_configure () {

    for s in $(find scripts/login-*);
    do
        log "Running $s on the login node..."
    done

}

agave_write_systems() {

    log "Creating executeSystem description..."
    sed -e "s|\${PUBLIC_IP}|${PUBLIC_IP}|g" -e "s|\${SERIALIZED_PUBLIC}|${SERIALIZED_PUBLIC}|g" -e "s|\${SERIALIZED_PRIVATE}|${SERIALIZED_PRIVATE}|g" templates/cfn-cluster.jsonx > cfn-cluster.json
    echo "Creating  storageSystem description..."
    sed -e "s|\${PUBLIC_IP}|${PUBLIC_IP}|g" -e "s|\${SERIALIZED_PUBLIC}|${SERIALIZED_PUBLIC}|g" -e "s|\${SERIALIZED_PRIVATE}|${SERIALIZED_PRIVATE}|g" templates/cfn-storage.jsonx > cfn-storage.json
    log "Done"
}

agave_enroll_systems() {

    log "Enrolling systems..."
    if [ -e "cfn-cluster.json" ];
    then
        systems-addupdate -F cfn-cluster.json
    fi
    if [ -e "cfn-storage.json" ];
    then
        systems-addupdate -F cfn-storage.json
    fi

}

cluster_create
cluster_get_status
cluster_get_keys
cluster_login_configure
agave_write_systems
agave_enroll_systems
