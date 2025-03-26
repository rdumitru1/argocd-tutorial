FROM alpine:latest
RUN apk add --no-cache bash curl
workdir /devops-hobbies
COPY app-success-rate.sh .
RUN chmod +x app-success-rate.sh