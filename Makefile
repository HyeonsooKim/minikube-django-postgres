apply-all:
	kubectl apply -f secrets/postgres-secret.yaml
	kubectl apply -f postgres/
	kubectl apply -f django/
	kubectl apply -f nginx/
	kubectl apply -f nginx/nginx-configmap.yaml

service:
	minikube service nginx

build-django:
	eval $$(minikube docker-env) && docker build -t minikube-django:latest -f django/Dockerfile .

down-nginx:
	minikube service --url nginx | xargs -I {} sh -c 'echo "Stopping nginx service at {}"; kubectl delete service nginx'
