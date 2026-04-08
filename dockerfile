FROM python:3.10

WORKDIR /app

# Install boto3
RUN pip install boto3

COPY lambda/lambda_function.py .

CMD ["python", "lambda_function.py"]