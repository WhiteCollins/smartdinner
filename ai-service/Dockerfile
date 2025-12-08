FROM python:3.11-slim

WORKDIR /app

# Pre-requisitos del sistema (opcional si alguna lib los requiere)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential && rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PYTHONUNBUFFERED=1
ENV PORT=8000

EXPOSE 8000

# Ajusta el módulo si cambiaste la estructura (src/main.py -> src.main:app)
CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]