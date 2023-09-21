#!/bin/bash

export REPOSITORY_PREFIX="$1"

if [[ -z "$REPOSITORY_PREFIX" ]]; then
    echo "Error: REPOSITORY_PREFIX is not set."
    echo "Usage: $0 <REPOSITORY_PREFIX>"
    exit 1
else
    echo "Starting the cleanup process for Kubernetes deployments..."

    echo "Deleting applications from Kubernetes..."
    ./scripts/deleteToKubernetes.sh

    echo "Waiting for 5 seconds to ensure all resources are released..."
    sleep 5

    # echo "Uninstalling MySQL for vets-db..."
    # helm uninstall vets-db -n spring-petclinic

    # echo "Uninstalling MySQL for visits-db..."
    # helm uninstall visits-db -n spring-petclinic

    # echo "Uninstalling MySQL for customers-db..."
    # helm uninstall customers-db -n spring-petclinic

    # echo "Waiting for 5 seconds to ensure all MySQL instances are removed..."
    # sleep 5

    echo "Deleting initial services configuration..."
    kubectl delete -f k8s/init-services

    echo "Deleting initial namespace configuration..."
    kubectl delete -f k8s/init-namespace/

    echo "Cleanup process completed!"
fi

