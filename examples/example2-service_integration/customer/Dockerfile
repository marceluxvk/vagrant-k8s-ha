FROM centos:7

EXPOSE 7100
RUN mkdir /app
ADD dist/main /app

WORKDIR /app
ENTRYPOINT ./main
