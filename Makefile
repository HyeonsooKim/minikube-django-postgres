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
	kubectl apply -f nginx/ingress.yaml

service:
	minikube service nginx

get-ingress-ip:
	minikube ip

setup-hosts:
	@echo "다음 내용을 /etc/hosts 파일에 추가하세요:"
	@echo "$$(minikube ip) django.local api.django.local"
	@echo "명령어: sudo sh -c 'echo \"$$(minikube ip) django.local api.django.local\" >> /etc/hosts'"