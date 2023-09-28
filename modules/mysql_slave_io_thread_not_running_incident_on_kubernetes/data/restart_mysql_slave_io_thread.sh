

#!/bin/bash



# Set the name of the Kubernetes pod and container running MySQL

POD_NAME=${MYSQL_POD_NAME}

CONTAINER_NAME=${MYSQL_CONTAINER_NAME}



# Restart the MySQL Slave IO thread

kubectl exec $POD_NAME -c $CONTAINER_NAME -- /usr/bin/mysql -uroot -p${MYSQL_PASSWORD} -e "STOP SLAVE IO_THREAD; START SLAVE IO_THREAD;"