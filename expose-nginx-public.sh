#!/bin/bash

# This script helps expose the Nginx service to the public internet
# It configures the server to allow traffic through the NodePort

# Get the NodePort for the Nginx service
NODE_PORT=$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}')
MINIKUBE_IP=$(minikube ip)

echo "=== Nginx Public Access Configuration ==="
echo "NodePort: $NODE_PORT"
echo "Minikube IP: $MINIKUBE_IP"
echo ""

# Detect the firewall type
if command -v ufw &> /dev/null; then
    echo "UFW firewall detected"
    echo "To open port $NODE_PORT, run:"
    echo "sudo ufw allow $NODE_PORT/tcp"
    echo ""
    
    read -p "Would you like to open this port now? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo ufw allow $NODE_PORT/tcp
        echo "Port $NODE_PORT opened in UFW firewall"
    fi
elif command -v firewall-cmd &> /dev/null; then
    echo "FirewallD detected"
    echo "To open port $NODE_PORT, run:"
    echo "sudo firewall-cmd --permanent --add-port=$NODE_PORT/tcp"
    echo "sudo firewall-cmd --reload"
    echo ""
    
    read -p "Would you like to open this port now? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        sudo firewall-cmd --permanent --add-port=$NODE_PORT/tcp
        sudo firewall-cmd --reload
        echo "Port $NODE_PORT opened in FirewallD"
    fi
else
    echo "No recognized firewall detected"
    echo "You may need to manually open port $NODE_PORT on your server"
fi

echo ""
echo "=== Access URLs ==="
echo "Local URL: http://$MINIKUBE_IP:$NODE_PORT"

# Try to get the public IP
PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || echo "YOUR_SERVER_IP")
echo "Public URL: http://$PUBLIC_IP:$NODE_PORT"
echo ""
echo "Note: If you're accessing this from outside your network, you may need to:"
echo "1. Configure port forwarding on your router to forward port $NODE_PORT to this server"
echo "2. Use your public IP address instead of the private IP"
echo ""
echo "To check if your service is publicly accessible, visit:"
echo "https://check-host.net/check-tcp?host=$PUBLIC_IP:$NODE_PORT"
