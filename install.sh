#!/bin/bash

echo "================================================="
echo "    Log Monitoring - Automated Setup             "
echo "================================================="
echo "What would you like to set up on this server?"
echo "1) Centralizer (Grafana + Loki + Local Promtail)"
echo "2) Agent (Promtail Only)"
echo "3) Exit"
echo "-------------------------------------------------"
read -p "Choose an option [1-3]: " OPCAO

# Checks and creates the generic .env if this is the first time
if [ ! -f .env ]; then
    echo -e "\n[!] .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "WARNING: The .env file has been created."
    echo "Please edit the .env file with your IPs, passwords, and JOB names, then run this script again."
    exit 1
fi

case $OPCAO in
    1)
        echo -e "\n[+] Preparing the Centralizer..."
        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
            echo "Error: Docker Compose not found. Install Docker first."
            exit 1
        fi

        echo "[+] Starting the Centralizer containers..."
        if docker compose version &> /dev/null; then
            docker compose up -d
        else
            docker-compose up -d
        fi
        echo "Centralizer running successfully! Access Grafana on port 3000."
        ;;
        
    2)
        echo -e "\n[+] Preparing the Agent (Promtail)..."
        if ! command -v docker &> /dev/null; then
            echo "Error: Docker not found. Install Docker first."
            exit 1
        fi
        
        # Loads the .env variables to display on screen and validate
        source .env

        echo "=> Configuration detected in .env:"
        echo "   - Sending to: $LOKI_URL"
        echo "   - Job: $AGENT_JOB_NAME"
        echo "   - Host: $AGENT_HOST_NAME"
        read -p "Would you like to continue with this data? (y/n): " CONTINUAR
        
        if [[ "$CONTINUAR" != "s" ]] && [[ "$CONTINUAR" != "y" ]]; then
            echo "Installation canceled. Edit the .env and try again."
            exit 0
        fi

        echo "[+] Starting the Promtail container..."
        docker run -d \
          --name promtail-agent \
          --restart unless-stopped \
          --env-file .env \
          -v $(pwd)/agent-config/promtail-config.yaml:/etc/promtail/config.yml \
          -v /var/log:/var/log:ro \
          -v $(pwd)/agent-data:/tmp \
          grafana/promtail:latest \
          -config.file=/etc/promtail/config.yml \
          -config.expand-env=true
          
        echo "Agent running! Logs are already being sent to the Centralizer."
        ;;
        
    3)
        echo "Exiting..."
        exit 0
        ;;
        
    *)
        echo "Invalid option! Run the script again."
        exit 1
        ;;
esac