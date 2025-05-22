apply-all:
	kubectl apply -f secrets/postgres-secret.yaml
	kubectl apply -f postgres/
	kubectl apply -f django/
	kubectl apply -f nginx/
	kubectl apply -f nginx/nginx-configmap.yaml

service:
	minikube service nginx
