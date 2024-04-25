FROM ubuntu:22.04

RUN apt update && apt install build-essential default-jre python3-pip -y

RUN pip install tqdm

COPY . /app
WORKDIR /app

WORKDIR /app/CRF

RUN ./configure
RUN make

WORKDIR /app

RUN mkdir -p tmp
