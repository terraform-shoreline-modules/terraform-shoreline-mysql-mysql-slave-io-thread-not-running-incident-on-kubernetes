
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# MySQL Slave IO thread not running incident on Kubernetes.
---

MySQL Slave IO thread not running incident refers to a situation where the IO thread on a MySQL slave server is not running. This results in the slave server not being able to receive updates from the master server, leading to a replication delay that can cause data inconsistencies and other issues. This type of incident requires immediate attention to ensure that the replication process is resumed to prevent data loss and ensure system stability.

### Parameters
```shell
export MYSQL_POD_NAME="PLACEHOLDER"

export MYSQL_SERVICE_NAME="PLACEHOLDER"

export MYSQL_CONTAINER_NAME="PLACEHOLDER"

export MYSQL_PASSWORD="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export MASTER_POD_NAME="PLACEHOLDER"

export SLAVE_POD_NAME="PLACEHOLDER"
```

## Debug

### Get the list of all MySQL pods
```shell
kubectl get pods -l app=mysql
```

### Check the logs of the MySQL pod to see if there are any errors related to the IO thread
```shell
kubectl logs ${MYSQL_POD_NAME} | grep "IO thread"
```

### Check the status of the MySQL replication process
```shell
kubectl exec ${MYSQL_POD_NAME} -- mysql -e "SHOW SLAVE STATUS\G"
```

### Check if the MySQL service is running
```shell
kubectl get svc ${MYSQL_SERVICE_NAME}
```

### Check if the MySQL configuration is correct
```shell
kubectl exec ${MYSQL_POD_NAME} -- mysql --verbose --help | grep "server-id"
```

### Check the resource utilization of the pod
```shell
kubectl top pod ${MYSQL_POD_NAME}
```

### Check if the pod is running on a node with sufficient resources
```shell
kubectl describe pod ${MYSQL_POD_NAME} | grep "Node:"
```

### Check the events related to the pod
```shell
kubectl describe pod ${MYSQL_POD_NAME} | grep "Events"
```

### Network connectivity issue between the master and slave databases.
```shell


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


```

## Repair

### Restart the MySQL Slave IO thread on the affected instance.
```shell


#!/bin/bash



# Set the name of the Kubernetes pod and container running MySQL

POD_NAME=${MYSQL_POD_NAME}

CONTAINER_NAME=${MYSQL_CONTAINER_NAME}



# Restart the MySQL Slave IO thread

kubectl exec $POD_NAME -c $CONTAINER_NAME -- /usr/bin/mysql -uroot -p${MYSQL_PASSWORD} -e "STOP SLAVE IO_THREAD; START SLAVE IO_THREAD;"


```