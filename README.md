# Log Monitoring Stack (Loki-Grafana-Promtail)

A lightweight and automated infrastructure for centralized logging. This project allows you to deploy a **Centralizer** (Log server) and multiple **Agents** (Log shippers) using Docker and a simplified Bash script.

## Architecture Overview

The system is divided into two main roles:

1. **Centralizer**: Receives and stores logs (Loki) and visualizes them (Grafana).
2. **Agent**: Sits on target servers, reads local log files (e.g., `/var/log/syslog`), and pushes them to the Centralizer.

## Project Structure

```
.
├── agent-config/
│   └── promtail-config.yaml      # Configuration for remote agents
├── config-centralizer/
│   ├── loki-config.yaml          # Loki server settings
│   └── promtail-local.yaml       # Promtail to monitor the centralizer itself
├── docs/
│   └── grafana-alert.md          # Guide for Google Chat alerts
├── .env.example                  # Environment variables template
├── docker-compose.yml            # Main stack definition
└── install.sh                    # Automated deployment script
```

## Prerequisites

Before starting, ensure the following are installed on your server:

- Docker (v20.10+)
- Docker Compose (v2.0+)
- Git

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/guiruyz/logs-monitoring.git
cd log-monitoring-system
```

### 2. Prepare Environment Variables

Copy the example template and fill in your specific details:

```bash
cp .env.example .env
nano .env
```

**Crucial Variables:**

- `GRAFANA_ADMIN_PASSWORD`: Your secure password for Grafana UI.
- `LOKI_URL`: The IP or DNS of your Centralizer server.
- `AGENT_JOB_NAME`: Category name for the logs (e.g., netbox-app).
- `AGENT_HOST_NAME`: Friendly name of the server being monitored.

### 3. Run the Installer

Give execution permissions to the script and run it:

```bash
chmod +x install.sh
./install.sh
```

Choose the appropriate option:

- **Option 1**: To set up the main server (Grafana + Loki + Promtail Local).
- **Option 2**: To set up an agent on a remote machine (Promtail only).

## Verification

### For Centralizer

1. Access Grafana: `http://<YOUR_IP>:3000`
2. Login with `admin` and the password set in `.env`.
3. Go to **Connections > Data Sources** and verify that Loki is connected to `http://loki:3100`.
4. Go to **Explore** and search for logs using the labels you defined.

### For Agent

Check the container status:

```bash
docker ps | grep promtail-agent
```

To view real-time shipping logs:

```bash
docker logs -f promtail-agent
```

## Security Notes

- **Port 3100**: The Loki port should be restricted via Firewall (UFW/IPTables) to only allow IPs from your Agents.
- **.env file**: Never commit your `.env` file to the repository. It is already included in `.gitignore`.
- **Read-only Logs**: The Agent mounts `/var/log` as Read-Only (`:ro`) to ensure it cannot modify your system logs.

## Setting up Alerts (Google Chat)

Refer to [docs/grafana-alert.md](docs/grafana-alert.md) for detailed instructions on how to configure the Google Chat Webhook and the real-time alerting rules.
