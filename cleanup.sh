#!/bin/bash

# Function to display header
display_header() {
    clear
    echo -e '\e[1;91m'
    echo "🔴 eOracle Node Cleanup Script 🔴"
    echo -e "\e[0m"
}

cleanup_eoracle() {
    display_header
    echo -e "\e[1;33m=== Starting Cleanup Process ===\e[0m"
    
    # Stop running containers
    echo "Stopping eOracle containers..."
    if cd $HOME/Eoracle-operator-setup/data-validator 2>/dev/null; then
        docker compose down -v 2>/dev/null
    fi
    
    # Remove all related docker containers and images
    echo "Removing Docker containers and images..."
    docker ps -a | grep 'eoracle' | awk '{print $1}' | xargs -r docker rm -f
    docker images | grep 'eoracle' | awk '{print $3}' | xargs -r docker rmi -f
    
    # Remove directories and files
    echo "Removing eOracle directories and files..."
    rm -rf $HOME/Eoracle-operator-setup
    rm -f $HOME/eoracle_rpc_config.txt
    rm -f $HOME/eoracle_address.txt

    # Clean Docker system (optional)
    echo "Cleaning Docker system..."
    docker system prune -f

    echo -e "\e[1;32m=== Cleanup Complete ===\e[0m"
    echo "You can now proceed with a fresh installation of eOracle node."
}

# Execute cleanup
cleanup_eoracle
