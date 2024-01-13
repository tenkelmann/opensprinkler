FROM multiarch/alpine:amd64-latest-stable as base-img

########################################
FROM base-img as build-img
RUN apk --no-cache add \
      bash \
      ca-certificates \
      g++ \
      unzip \
      wget \
      mosquitto-dev
RUN wget https://github.com/OpenSprinkler/OpenSprinkler-Firmware/archive/master.zip && \
    unzip master.zip && \
    cd /OpenSprinkler-Firmware-master && \
    echo "Building OpenSprinkler..." && \
    g++ -o OpenSprinkler -DOSPI -std=c++14 main.cpp OpenSprinkler.cpp program.cpp opensprinkler_server.cpp utils.cpp weather.cpp gpio.cpp etherport.cpp mqtt.cpp -lpthread -lmosquitto 

########################################
FROM base-img
RUN apk --no-cache add \
      libstdc++ \
      mosquitto \
      mosquitto-libs \
    && \
    mkdir /OpenSprinkler && \
    mkdir -p /data/logs && \
    cd /OpenSprinkler && \
    ln -s /data/stns.dat && \
    ln -s /data/nvm.dat && \
    ln -s /data/ifkey.txt && \
    ln -s /data/logs
COPY --from=build-img /OpenSprinkler-Firmware-master/OpenSprinkler /OpenSprinkler/OpenSprinkler
WORKDIR /OpenSprinkler

#-- Logs and config information go into the volume on /data
VOLUME /data

#-- OpenSprinkler interface is available on 8080
EXPOSE 8080

CMD [ "./OpenSprinkler" ]r
