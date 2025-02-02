FROM python:3.11-slim

WORKDIR /wrk

COPY /app /wrk/

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 8080

CMD ["python", "main.py"]