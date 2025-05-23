FROM python:3.12
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app
COPY ./django /app

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ["gunicorn", "minikube_django.wsgi:application", "--bind", "0.0.0.0:8000"]
