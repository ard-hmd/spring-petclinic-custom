#!/bin/bash

export REPOSITORY_PREFIX="$1"

if [[ -z "$REPOSITORY_PREFIX" ]]; then
    echo "Error: REPOSITORY_PREFIX is not set."
    echo "Usage: $0 <REPOSITORY_PREFIX>"
    exit 1
else
    echo "Setting up the Kubernetes environment..."

    echo "Applying initial namespace configuration..."
    kubectl apply -f k8s/init-namespace

    echo "Applying initial services configuration..."
    kubectl apply -f k8s/init-services

    echo "Waiting for 5 seconds to ensure services are initialized..."
    sleep 5

    # echo "Adding bitnami helm repo"
    # helm repo add bitnami https://charts.bitnami.com/bitnami

    # echo "Updating helm repo"
    # helm repo update

    echo "Deploying MySQL for vets-db..."
    # helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    helm install vets-db ./k8s_db/mysql-replication-chart/ --namespace spring-petclinic

    echo "Deploying MySQL for visits-db..."
    # helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    helm install visits-db ./k8s_db/mysql-replication-chart/ --namespace spring-petclinic

    echo "Deploying MySQL for customers-db..."
    # helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    helm install customers-db ./k8s_db/mysql-replication-chart/ --namespace spring-petclinic

    echo "Waiting for 90 seconds to ensure MySQL deployments are up and running..."
    sleep 90

    echo "Deploying applications to Kubernetes..."
    ./scripts/deployToKubernetes.sh

    echo "Waiting for 30 seconds to ensure others deployments are up and running..."
    sleep 30

    echo "Try this following URL: http://$(kubectl get svc -n spring-petclinic api-gateway |awk '{print $4}' |tail -n +2)"
    
    echo "Deployment process completed!"
fi

