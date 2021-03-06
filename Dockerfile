FROM ubuntu:18.04

# INSTALL REQUIREMENTS
RUN apt-get update && apt-get install -y git build-essential cmake qtbase5-dev libqt5svg5-dev libqt5svg5-dev libavahi-client-dev && rm -rf /var/lib/apt/lists/*

# CLONES, building these manually because there are no ARM depos..
RUN git clone --progress --verbose  https://github.com/pothosware/SoapyRemote.git
RUN git clone --progress --verbose  https://github.com/pothosware/SoapySDR.git

# INSTALL SOAPY
WORKDIR /SoapySDR/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN make install -j8

# INSTALL SOAPY-REMOTE
WORKDIR /SoapyRemote/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr ..
RUN make install -j8

WORKDIR /
ADD ./ ./gqrx
WORKDIR /gqrx/build
RUN cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_CXX_STANDARD_LIBRARIES="-lSoapySDR" ..
RUN make install -j8

WORKDIR /
ADD ./default.conf ./
WORKDIR /

CMD /etc/init.d/dbus start; /etc/init.d/avahi-daemon start; gqrx
