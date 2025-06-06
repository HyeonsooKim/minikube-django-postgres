
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
	echo "  ssh -L 8080:$${MINIKUBE_IP}:$${NGINX_PORT} $(whoami)@YOUR_SERVER_IP -N" && \
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

tunnel-nginx:
	@echo "Setting up SSH tunnel for nginx service..."
	@NGINX_PORT=$$(kubectl get svc nginx -o jsonpath='{.spec.ports[0].nodePort}') && \
	MINIKUBE_IP=$$(minikube ip) && \
	echo "You can access nginx at: http://$${MINIKUBE_IP}:$${NGINX_PORT}" && \
	echo "To make this accessible from outside, run on your local machine:" && \
	echo "ssh -L 8080:$${MINIKUBE_IP}:$${NGINX_PORT} $(whoami)@YOUR_SERVER_IP -N"

# ===== Monitoring Commands =====
status:
	@echo "📊 Checking status of all services..."
	@echo "\n🔍 Pods:"
	@kubectl get pods
	@echo "\n🔍 Services:"
	@kubectl get svc
	@echo "\n🔍 Deployments:"
	@kubectl get deployments

debug-django:
	@echo "🔍 Debugging Django pod issues..."
	@echo "\nPod details:"
	@kubectl describe pod -l app=django
	@echo "\nLogs (if pod exists):"
	@kubectl logs -l app=django --tail=50 || echo "⚠️ No logs available"
	@echo "\nDocker image status:"
	@eval $$(minikube docker-env) && docker images | grep minikube-django || echo "⚠️ No Django image found in minikube"
