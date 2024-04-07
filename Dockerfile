FROM ubuntu:22.04

RUN apt update && apt install build-essential default-jre -y

COPY . /app
WORKDIR /app

WORKDIR /app/CRF

RUN ./configure
RUN make

WORKDIR /app

