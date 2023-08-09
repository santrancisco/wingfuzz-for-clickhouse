FROM clickhouse/binary-builder

RUN apt update && \
    apt install -y unixodbc-dev && \
    apt clean

COPY clickhouse-odbc /clickhouse-odbc

RUN cd /clickhouse-odbc && \
    rm -rf build && \
    mkdir -p build && \
    cd build && \
    cmake ..  && \
    make -j && \
    mkdir -p /opt/wfuzz/lib && \
    cp driver/libclickhouseodbc.so driver/libclickhouseodbcw.so /opt/wfuzz/lib

COPY aflpp /aflpp

RUN cd /aflpp && \
    LLVM_CONFIG=llvm-config-16 make PREFIX=/opt/wfuzz install -j

COPY wfuzz.tar.gz /

RUN cd /opt && \
    tar xzvf /wfuzz.tar.gz

FROM clickhouse/binary-builder

RUN wget http://security.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost1.71-dev_1.71.0-6ubuntu6_amd64.deb

RUN wget http://security.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-serialization1.71.0_1.71.0-6ubuntu6_amd64.deb

RUN wget http://security.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-serialization1.71-dev_1.71.0-6ubuntu6_amd64.deb

RUN wget http://security.ubuntu.com/ubuntu/pool/main/b/boost1.71/libboost-program-options1.71.0_1.71.0-6ubuntu6_amd64.deb

RUN dpkg -i libboost1.71-dev_1.71.0-6ubuntu6_amd64.deb

RUN dpkg -i libboost-serialization1.71.0_1.71.0-6ubuntu6_amd64.deb

RUN dpkg -i libboost-serialization1.71-dev_1.71.0-6ubuntu6_amd64.deb

RUN dpkg -i libboost-program-options1.71.0_1.71.0-6ubuntu6_amd64.deb

RUN apt update && \
    apt install -y unixodbc-dev unixodbc libsqlite3-dev && \
    apt clean

COPY --from=0 /opt/wfuzz /opt/wfuzz

ENV WFUZZ_PATH=/opt/wfuzz