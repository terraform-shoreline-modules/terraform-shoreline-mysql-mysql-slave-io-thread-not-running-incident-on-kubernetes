

#!/bin/bash



# Set the namespace and pod names

NAMESPACE=${NAMESPACE}

MASTER_POD=${MASTER_POD_NAME}

SLAVE_POD=${SLAVE_POD_NAME}



# Check if the master and slave pods are running

MASTER_STATUS=$(kubectl get pods -n $NAMESPACE $MASTER_POD -o jsonpath='{.status.phase}')

SLAVE_STATUS=$(kubectl get pods -n $NAMESPACE $SLAVE_POD -o jsonpath='{.status.phase}')



if [[ $MASTER_STATUS != "Running" ]]; then

    echo "Error: Master pod is not running."

    exit 1

fi



if [[ $SLAVE_STATUS != "Running" ]]; then

    echo "Error: Slave pod is not running."

    exit 1

fi



# Check if the master and slave pods are in the same network

MASTER_IP=$(kubectl get pod -n $NAMESPACE $MASTER_POD -o jsonpath='{.status.podIP}')

SLAVE_IP=$(kubectl get pod -n $NAMESPACE $SLAVE_POD -o jsonpath='{.status.podIP}')



if [[ $MASTER_IP == $SLAVE_IP ]]; then

    echo "Error: Master and slave pods are on the same IP address."

    exit 1

fi



# Check the network connectivity between the master and slave pods

nc -w 5 -z $MASTER_IP 3306

if [[ $? -ne 0 ]]; then

    echo "Error: Unable to connect to the master database."

    exit 1

fi



nc -w 5 -z $SLAVE_IP 3306

if [[ $? -ne 0 ]]; then

    echo "Error: Unable to connect to the slave database."

    exit 1

fi



echo "Network connectivity between the master and slave databases is OK."

exit 0