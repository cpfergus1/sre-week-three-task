NAMESPACE="sre"
DEPLOYMENT_NAME="swype-app"
MAX_RESTARTS=3

# Start the monitoring loop
while true; do
    # Get the number of restarts for the pods associated with the deployment
    # Assumes pods have a label 'app' that matches the deployment name
    RESTART_COUNT=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME -o jsonpath='{.items[*].status.containerStatuses[*].restartCount}' | awk '{s+=$1} END {print s}')

    # Display the current number of restarts
    echo "Current restart count: $RESTART_COUNT"

    # Check if the restart limit has been exceeded
    if [ "$RESTART_COUNT" -gt "$MAX_RESTARTS" ]; then
        echo "Restart limit exceeded. Scaling down the deployment..."
        kubectl scale deployment/$DEPLOYMENT_NAME --replicas=0 -n $NAMESPACE
        break
    else
        # Pause for 60 seconds
        sleep 60
    fi
done