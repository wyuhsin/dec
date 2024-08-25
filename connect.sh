#!/bin/bash

CONFIG_FILE="connections.yaml"

# check if yq is installed
if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Please install yq 4."
    exit 1
fi

# select connection type
echo "Select connection type:"
select type in ssh mysql mongo redis; do
    case $type in
        ssh)
            servers=$(yq eval '.ssh[].name' $CONFIG_FILE)
            ;;
        mysql)
            servers=$(yq eval '.mysql[].name' $CONFIG_FILE)
            ;;
        mongo)
            servers=$(yq eval '.mongo[].name' $CONFIG_FILE)
            ;;
        redis)
            servers=$(yq eval '.redis[].name' $CONFIG_FILE)
            ;;
        *)
            echo "Invalid selection."
            exit 1
            ;;
    esac
    break
done

# select specific server
echo "Select server:"
select server in $servers; do
    case $type in
        ssh)
            config=$(yq eval ".ssh[] | select(.name == \"$server\")" $CONFIG_FILE)
            ;;
        mysql)
            config=$(yq eval ".mysql[] | select(.name == \"$server\")" $CONFIG_FILE)
            ;;
        mongo)
            config=$(yq eval ".mongo[] | select(.name == \"$server\")" $CONFIG_FILE)
            ;;
        redis)
            servers=$(yq eval '.redis[].name' $CONFIG_FILE)
            ;;
    esac
    break
done

# display selected configuration
echo "Selected configuration:"
echo "$config"

host=$(echo "$config" | yq eval '.host' -)
user=$(echo "$config" | yq eval '.user' -)
password=$(echo "$config" | yq eval '.password' -)

# execute connection based on selected type
case $type in
    ssh)
        echo "Connecting to SSH server $host..."
        sshpass -p "$password" ssh "$user@$host"
        ;;
    mysql)
        echo "Connecting to MySQL server $host..."
        mysql -h "$host" -u "$user" -p"$password"
        ;;
    mongo)
        echo "Connecting to MongoDB server $host..."
        mongo --host "$host" --username "$user" --password "$password"
        ;;
    redis)
        echo "Connecting to Redis server $host..."
        redis-cli -h "$host" -p "$port" -a "$password"
        ;;
esac

