
# ===== Build Commands =====
build-django:
	@echo "🔨 Building Django Docker image..."
	eval $$(minikube docker-env) && docker build -t minikube-django:latest -f django/Dockerfile .
	@echo "✅ Django image built successfully!"
	@eval $$(minikube docker-env) && docker images | grep minikube-django

rebuild-django: build-django
	@echo "Redeploying Django service..."
	@kubectl delete -f django/django-deployment.yaml || true
	@kubectl apply -f django/django-deployment.yaml
	@echo "Django service redeployed successfully"

# ===== Deployment Commands =====
apply-all:
	kubectl apply -f secrets/postgres-secret.yaml
	kubectl apply -f postgres/
	kubectl apply -f django/
	kubectl apply -f nginx/
	kubectl apply -f nginx/nginx-configmap.yaml

enable-ingress:
	@echo "🚀 Enabling Nginx Ingress Controller in Minikube..."
	@chmod +x enable-ingress.sh
	@./enable-ingress.sh
	@echo "✅ Nginx Ingress Controller enabled successfully!"

apply-ingress: enable-ingress
	@echo "🚀 Applying Ingress resources..."
	@kubectl apply -f nginx/ingress.yaml
	@echo "✅ Ingress resources applied successfully!"
	@echo "\n🔍 Ingress status:"
	@kubectl get ingress
	@echo "\n🌐 Ingress IP (may take a moment to be assigned):"
	@kubectl get ingress django-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}' || echo "IP not yet assigned"

run-all: build-django apply-all
	@echo "\n🚀 Starting all services: Postgres, Django, and Nginx...\n"
	@echo "✅ Services are starting up, please wait a moment..."
	@sleep 10
	@echo "\n📊 Checking pod status:"
	@kubectl get pods
	@echo "\n⏳ Waiting for Django pod to be ready..."
	@kubectl wait --for=condition=ready --timeout=120s pod -l app=django || echo "⚠️ Timeout waiting for Django pod. Check status with 'kubectl describe pod -l app=django'"
	@echo "\n🔗 Your application will be available at:"
	@minikube service nginx --url
	@echo "\n🌐 SSH tunnel setup for remote access:"
	@NGINX_PORT=$$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}') && \
	MINIKUBE_IP=$$(minikube ip) && \
	echo "→ Local access URL: http://$${MINIKUBE_IP}:$${NGINX_PORT}" && \
	echo "→ For remote access, run on your local machine:" && \
	echo "  ssh -L 8080:$${MINIKUBE_IP}:$${NGINX_PORT} $(whoami)@10.0.0.11 -N" && \
	echo "  Then open: http://localhost:8080 in your browser"

down-all:
	@echo "🛑 Stopping all services: Nginx, Django, and Postgres..."
	@kubectl delete -f nginx/ || true
	@kubectl delete -f django/ || true
	@kubectl delete -f postgres/ || true
	@kubectl delete -f secrets/postgres-secret.yaml || true
	@echo "✅ All services stopped"

# ===== Nginx Service Access Commands =====
service:
	minikube service nginx

get-nginx-url:
	@echo "Nginx service URL:"
	@minikube service nginx --url

expose-nginx:
	@echo "Exposing nginx service on port 8080 of the remote server..."
	@kubectl port-forward --address 0.0.0.0 service/nginx 8080:80

expose-nginx-public:
	@echo "🌐 Exposing Nginx service publicly..."
	@NODE_PORT=$$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}') && \
	MINIKUBE_IP=$$(minikube ip) && \
	echo "✅ Nginx is now publicly accessible at:" && \
	echo "🔗 Local URL: http://$${MINIKUBE_IP}:$${NODE_PORT}" && \
	echo "🌍 Public URL (use your server's public IP): http://10.0.0.11:$${NODE_PORT}" && \
	echo "\n💡 If your server has a firewall, make sure port $${NODE_PORT} is open" && \
	echo "📝 To open the port on your server, you can run:" && \
	echo "   sudo ufw allow $${NODE_PORT}/tcp    # for UFW firewall" && \
	echo "   sudo firewall-cmd --permanent --add-port=$${NODE_PORT}/tcp    # for firewalld"

open-nginx-firewall:
	@echo "🔓 Running script to open firewall ports for Nginx..."
	@./expose-nginx-public.sh

tunnel-nginx:
	@echo "Setting up SSH tunnel for nginx service..."
	@NGINX_PORT=$$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}') && \
	MINIKUBE_IP=$$(minikube ip) && \
	echo "You can access nginx at: http://$${MINIKUBE_IP}:$${NGINX_PORT}" && \
	echo "To make this accessible from outside, run on your local machine:" && \
	echo "ssh -L 8080:$${MINIKUBE_IP}:$${NGINX_PORT} $(whoami)@10.0.0.11 -N"

# ===== Monitoring Commands =====
status:
	@echo "📊 Checking status of all services..."
	@echo "\n🔍 Pods:"
	@kubectl get pods
	@echo "\n🔍 Services:"
	@kubectl get svc
	@echo "\n🔍 Deployments:"
	@kubectl get deployments
	@echo "\n🔍 Ingress:"
	@kubectl get ingress

scale-django:
	@echo "🔄 Scaling Django deployment to $(REPLICAS) replicas..."
	@kubectl scale deployment/django --replicas=$(REPLICAS)
	@echo "✅ Django scaled to $(REPLICAS) replicas"
	@echo "\n📊 Current pod status:"
	@kubectl get pods -l app=django

debug-django:
	@echo "🔍 Debugging Django pod issues..."
	@echo "\nPod details:"
	@kubectl describe pod -l app=django
	@echo "\nLogs (if pod exists):"
	@kubectl logs -l app=django --tail=50 || echo "⚠️ No logs available"
	@echo "\nDocker image status:"
	@eval $$(minikube docker-env) && docker images | grep minikube-django || echo "⚠️ No Django image found in minikube"

nginx-logs:
	@echo "📋 Fetching Nginx access logs..."
	@POD_NAME=$$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}') && \
	kubectl exec -it $${POD_NAME} -- tail -f /var/log/nginx/access.log
