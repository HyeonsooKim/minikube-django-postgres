kube-start:
	minikube start --driver=docker --listen-address=0.0.0.0

build-django:
	# Build the Django image in Minikube's Docker daemon
	eval $(minikube docker-env)
	docker build -t minikube-django:latest -f django/Dockerfile .

apply-all:
	kubectl apply -f secrets/postgres-secret.yaml
	kubectl apply -f postgres/
	kubectl apply -f django/
	kubectl apply -f nginx/
	kubectl apply -f nginx/nginx-configmap.yaml

service:
	minikube service nginx
