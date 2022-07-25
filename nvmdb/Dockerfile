FROM gcc:latest
COPY . /
WORKDIR /
RUN apt-get update
RUN apt-get install --yes gdb
RUN make
CMD ["./nvmdb"]
