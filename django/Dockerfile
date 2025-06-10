FROM python:3.12
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# 필요한 파일만 복사 (Django 프로젝트와 requirements만)
COPY django/requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r requirements.txt

# Django 프로젝트 파일만 복사
COPY django/ /app/

# 실행 권한 확인
RUN chmod +x /app/entrypoint.sh || echo "No entrypoint script found"

# health check 추가
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8000/ || exit 1

# 기본 포트 명시
EXPOSE 8000

# gunicorn으로 실행
CMD ["gunicorn", "minikube_django.wsgi:application", "--bind", "0.0.0.0:8000"]
