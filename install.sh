#!/bin/bash

echo "================================================="
echo "   Monitoramento de Logs - Setup Automatizado    "
echo "================================================="
echo "O que você deseja configurar neste servidor?"
echo "1) Centralizador (Grafana + Loki + Promtail Local)"
echo "2) Agente (Apenas Promtail)"
echo "3) Sair"
echo "-------------------------------------------------"
read -p "Escolha uma opção [1-3]: " OPCAO

# Verifica e cria o .env genérico se for a primeira vez
if [ ! -f .env ]; then
    echo -e "\n[!] Arquivo .env não encontrado. Criando a partir do .env.example..."
    cp .env.example .env
    echo "⚠️ ATENÇÃO: O arquivo .env foi criado."
    echo "Por favor, edite o arquivo .env com seus IPs, senhas e nomes de JOB, e depois rode este script novamente."
    exit 1
fi

case $OPCAO in
    1)
        echo -e "\n[+] Preparando o Centralizador..."
        if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
            echo "Erro: Docker Compose não encontrado. Instale o Docker primeiro."
            exit 1
        fi

        echo "[+] Subindo os containers do Centralizador..."
        if docker compose version &> /dev/null; then
            docker compose up -d
        else
            docker-compose up -d
        fi
        echo "✅ Centralizador rodando com sucesso! Acesse o Grafana na porta 3000."
        ;;
        
    2)
        echo -e "\n[+] Preparando o Agente (Promtail)..."
        if ! command -v docker &> /dev/null; then
            echo "Erro: Docker não encontrado. Instale o Docker primeiro."
            exit 1
        fi
        
        # Carrega as variáveis do .env só para mostrar na tela e validar
        source .env

        echo "=> Configuração detectada no .env:"
        echo "   - Enviando para: $LOKI_URL"
        echo "   - Job: $AGENT_JOB_NAME"
        echo "   - Host: $AGENT_HOST_NAME"
        read -p "Deseja continuar com esses dados? (s/n): " CONTINUAR
        
        if [[ "$CONTINUAR" != "s" ]]; then
            echo "Instalação cancelada. Edite o .env e tente novamente."
            exit 0
        fi

        echo "[+] Subindo o container do Promtail..."
        docker run -d \
          --name promtail-agent \
          --restart unless-stopped \
          --env-file .env \
          -v $(pwd)/agent-config/promtail-config.yaml:/etc/promtail/config.yml \
          -v /var/log:/var/log:ro \
          grafana/promtail:latest \
          -config.file=/etc/promtail/config.yml \
          -config.expand-env=true
          
        echo "✅ Agente rodando! Os logs já estão sendo enviados para o Centralizador."
        ;;
        
    3)
        echo "Saindo..."
        exit 0
        ;;
        
    *)
        echo "Opção inválida! Execute o script novamente."
        exit 1
        ;;
esac