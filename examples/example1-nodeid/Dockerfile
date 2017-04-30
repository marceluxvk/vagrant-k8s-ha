FROM centos:7

EXPOSE 7000
RUN mkdir /app
ADD dist/main /app

WORKDIR /app
ENTRYPOINT ./main

