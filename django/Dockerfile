FROM python:3.12
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /app

# Copy requirements first for better caching
COPY django/requirements.txt /app/
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the rest of the application
COPY django/ /app/

# Make the entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Use the entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]

# Command to run after entrypoint
CMD ["gunicorn", "minikube_django.wsgi:application", "--bind", "0.0.0.0:8000"]
