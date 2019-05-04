FROM tiangolo/uwsgi-nginx-flask:python3.7-alpine3.8
COPY ./app /app
RUN pip install -U pip && \
    pip install -r /app/requirements.txt
ENV MESSAGE "GoodRx AMI Builds API"
