#!/bin/bash

# Header display function with logo and IP
display_header() {
    clear
    echo -e '\e[1;92m'
    echo -e ' █████╗ ██╗   ██╗ █████╗ ██╗  ██╗                                '
    echo -e '██╔══██╗██║   ██║██╔══██╗██║  ██║                                '
    echo -e '███████║██║   ██║███████║███████║                                '
    echo -e '██╔══██║██║   ██║██╔══██║██╔══██║                                '
    echo -e '██║  ██║╚██████╔╝██║  ██║██║  ██║                                '
    echo -e '╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝                                '
    echo -e '                                                                     '
    echo -e '   \e[1;91mCommunity ahh.. ahh.. ahh..\e[1;92m                     '
    echo -e '                                                                     '
    
    # Get the IP address of the machine
    IP_ADDRESS=$(curl -s https://api.ipify.org)
    echo -e "\e[1;91mIP address: $IP_ADDRESS\e[0m"
    echo -e "\e[0m" # Reset color
}

# Function to configure RPC endpoints
configure_rpc() {
    display_header
    echo -e "\e[1;33m=== RPC Configuration ===\e[0m"
    echo "Choose RPC configuration:"
    echo "1. Use default RPC endpoints"
    echo "2. Enter custom RPC endpoints"
    read -p "Enter your choice (1-2): " rpc_choice

    case $rpc_choice in
        1)
            ETH_RPC="https://holesky.drpc.org"
            ETH_FEED_RPC="https://rpc.ankr.com/eth"
            BSC_FEED_RPC="https://bsc.blockpi.network/v1/rpc/public"
            ;;
        2)
            echo -e "\nEnter custom RPC endpoints:"
            read -p "ETH RPC (Holesky) endpoint: " ETH_RPC
            read -p "Ethereum Feed RPC endpoint: " ETH_FEED_RPC
            read -p "BSC Feed RPC endpoint: " BSC_FEED_RPC
            ;;
        *)
            echo "Invalid choice. Using default RPC endpoints."
            ETH_RPC="https://holesky.drpc.org"
            ETH_FEED_RPC="https://rpc.ankr.com/eth"
            BSC_FEED_RPC="https://bsc.blockpi.network/v1/rpc/public"
            ;;
    esac

    # Save RPC configuration
    cat > "$HOME/eoracle_rpc_config.txt" << EOF
ETH_RPC=$ETH_RPC
ETH_FEED_RPC=$ETH_FEED_RPC
BSC_FEED_RPC=$BSC_FEED_RPC
EOF
}

# Function to set passphrase
set_passphrase() {
    display_header
    echo -e "\e[1;33m=== Passphrase Configuration ===\e[0m"
    while true; do
        read -s -p "Enter your passphrase (minimum 8 characters): " EO_PASSPHRASE
        echo
        if [ ${#EO_PASSPHRASE} -ge 8 ]; then
            read -s -p "Confirm passphrase: " CONFIRM_PASS
            echo
            if [ "$EO_PASSPHRASE" = "$CONFIRM_PASS" ]; then
                break
            else
                echo "Passphrases do not match. Please try again."
            fi
        else
            echo "Passphrase must be at least 8 characters long."
        fi
    done

    # Save passphrase to config
    echo "EO_PASSPHRASE=$EO_PASSPHRASE" >> "$HOME/eoracle_rpc_config.txt"
}

# Backup function
create_backup() {
    local backup_dir="$HOME/eoracle-backup-$(date +%Y-%m-%d-%H-%M-%S)"
    mkdir -p "$backup_dir"

    # Backup important files
    if [ -d "$HOME/Eoracle-operator-setup" ]; then
        # Backup .env and keystore
        cd "$HOME/Eoracle-operator-setup"
        cp data-validator/.env "$backup_dir/" 2>/dev/null || true
        cp -r .keystore/ "$backup_dir/" 2>/dev/null || true
        
        # Backup configurations
        cp "$HOME/eoracle_rpc_config.txt" "$backup_dir/" 2>/dev/null || true
        
        # If alias address exists, back it up
        if [ -f "$HOME/eoracle_address.txt" ]; then
            cp "$HOME/eoracle_address.txt" "$backup_dir/"
        fi
        
        echo -e "\e[1;32m=== Backup Created ===\e[0m"
        echo "Backup location: $backup_dir"
        echo "Files backed up:"
        ls -la "$backup_dir"
    else
        echo "No files to backup yet."
    fi
}

# Install dependencies function
install_dependencies() {
    display_header
    echo -e "\e[1;33m=== Installing Dependencies ===\e[0m"
    
    # Update and upgrade system
    sudo apt update && sudo apt upgrade -y
    
    # Install prerequisites
    sudo apt-get install git -y
    sudo ufw allow 3000/tcp && sudo ufw allow 9090/tcp
    
    # Install Docker if not already installed
    if ! command -v docker &> /dev/null
    then
        echo "Installing Docker..."
        sudo apt install docker.io -y
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo "Docker already installed. Version: $(docker --version)"
    fi
    
    echo -e "\e[1;32mDependencies installed successfully.\e[0m"
    read -n1 -r -p "Press any key to continue..." key
}

# Setup and run node function
setup_node() {
    display_header
    echo -e "\e[1;33m=== Setting up eOracle Node ===\e[0m"
    
    # Configure RPC and passphrase if not already done
    if [ ! -f "$HOME/eoracle_rpc_config.txt" ]; then
        configure_rpc
        set_passphrase
    fi
    
    # Clone repository
    cd $HOME
    git clone https://github.com/Eoracle/Eoracle-operator-setup.git
    cd Eoracle-operator-setup

    # Setup .env file
    cp data-validator/.example_env_holesky data-validator/.env
    
    # Configure .env with saved settings
    source "$HOME/eoracle_rpc_config.txt"
    sed -i "s|ETH_RPC_ENDPOINT=.*|ETH_RPC_ENDPOINT=$ETH_RPC|g" data-validator/.env
    sed -i "s|ETHEREUM_FEED_RPC_ENDPOINT=.*|ETHEREUM_FEED_RPC_ENDPOINT=$ETH_FEED_RPC|g" data-validator/.env
    sed -i "s|BSC_FEED_RPC_ENDPOINT=.*|BSC_FEED_RPC_ENDPOINT=$BSC_FEED_RPC|g" data-validator/.env
    sed -i "s|EO_PASSPHRASE=.*|EO_PASSPHRASE=$EO_PASSPHRASE|g" data-validator/.env

    # Generate BLS key
    echo -e "\n\e[1;33m=== Generating BLS Key ===\e[0m"
    ./run.sh generate-bls-key
    echo -e "\e[1;31mIMPORTANT: Please save your BLS key information shown above!\e[0m"
    read -p "Press Enter once you have saved your BLS key..."

    # Encrypt keys
    echo -e "\n\e[1;33m=== Encrypting Keys ===\e[0m"
    read -p "Enter your ECDSA private key: " ecdsa_key
    read -p "Enter your BLS private key: " bls_key
    ./run.sh encrypt "$ecdsa_key" "$bls_key"

    # Register with eOracle AVS
    echo -e "\n\e[1;33m=== Registering with eOracle AVS ===\e[0m"
    ./run.sh register

    # Generate and declare alias
    echo -e "\n\e[1;33m=== Generating Alias ===\e[0m"
    ./run.sh generate-alias
    
    # Save alias address
    alias_address=$(ls -la .keystore | grep "alias" | awk '{print $9}' | cut -d'-' -f2)
    if [ ! -z "$alias_address" ]; then
        echo "Your alias address: $alias_address" > "$HOME/eoracle_address.txt"
        echo -e "\e[1;32mYour alias address has been saved to: $HOME/eoracle_address.txt\e[0m"
        echo -e "\e[1;31mIMPORTANT: Get Holesky testnet ETH for this address!\e[0m"
    fi

    ./run.sh declare-alias

    # Create backup
    create_backup

    # Start the validator
    echo -e "\n\e[1;33m=== Starting eOracle Validator ===\e[0m"
    cd $HOME/Eoracle-operator-setup/data-validator && docker compose up -d
    
    echo -e "\e[1;32m=== Node Setup Complete ===\e[0m"
    echo "Your node is now running!"
    read -n1 -r -p "Press any key to continue..." key
}

# View logs function
view_logs() {
    clear
    echo "Viewing eOracle node logs..."
    cd $HOME/Eoracle-operator-setup/data-validator && docker compose logs -f
}

# Main menu function
main_menu() {
    while true; do
        display_header
        echo "Please select an option:"
        echo "1. Install dependencies"
        echo "2. Setup & Run Node"
        echo "3. View logs"
        echo "4. Create backup"
        echo "5. Exit"
        read -p "Enter your choice (1-5): " choice
        case $choice in
            1)
                install_dependencies
                ;;
            2)
                setup_node
                ;;
            3)
                view_logs
                ;;
            4)
                create_backup
                read -n1 -r -p "Press any key to continue..." key
                ;;
            5)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please try again."
                read -n1 -r -p "Press any key to continue..." key
                ;;
        esac
    done
}

# Start the script
main_menu
