# minikube-django-postgres

`Minikube`, `Django`, `PostgreSQL` 로 구성된 단일 클러스터를 구성하여 K8S 를 체험하기 위한 저장소.

## Secrets 구성

`secrets` 폴더 하위에 아래 파일을 추가해야 합니다.

- postgres-secret.yaml

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
data:
  POSTGRES_PASSWORD: custom-password
```