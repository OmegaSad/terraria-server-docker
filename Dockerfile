FROM debian:12-slim AS base

ARG VERSION=latest

ENV TERRARIA_VERSION=$VERSION
ENV TERRARIA_DIR=/root/.local/share/Terraria
ENV PATH="${TERRARIA_DIR}:${PATH}"

RUN mkdir -p ${TERRARIA_DIR}

WORKDIR ${TERRARIA_DIR}

COPY ./scripts/* .

RUN chmod +x \
    create-server-config.sh \
    init-TerrariaServer-amd64.sh \
    init-TerrariaServer-arm64.sh \
    download_server.py \
    prune_unused_files.py \
    get_latest_version.py

RUN apt-get update -qq && apt-get -qq install python3 && rm -rf /var/lib/apt/lists/*
RUN python3 download_server.py ${TERRARIA_VERSION} && python3 prune_unused_files.py && apt-get -qq purge python3 && apt-get -qq autoremove 

RUN mkdir -p ${TERRARIA_DIR}/Worlds && rm -dR __pycache__ \
    changelog.txt \
    download_server.py \
    prune_unused_files.py \
    get_latest_version.py \
    get_latest_version.cpython-314.pyc \
    Terraria.png

ENV autocreate=1 \
    seed='' \
    difficulty=1 \
    maxplayers=16 \
    port=7777 \
    password='' \
    motd="Welcome!" \
    worldpath=${TERRARIA_DIR}/Worlds \
    banlist=banlist.txt \
    secure=1 \
    language=en/US \
    upnp=1 \
    npcstream=1 \
    priority=1


### amd-64 ###
FROM base AS build-amd64

RUN chmod +x TerrariaServer.bin.x86_64

ENTRYPOINT [ "./init-TerrariaServer-amd64.sh" ]

### arm-64 ###

#FROM mono:slim AS build-arm64
#
#ENV TERRARIA_DIR=/root/.local/share/TerrariaARM
#
#ENV PATH="${TERRARIA_DIR}:${PATH}" \
#    autocreate=1 \
#    seed='' \
#    difficulty=1 \
#    maxplayers=16 \
#    port=7777 \
#    password='' \
#    motd="Welcome!" \
#    worldpath=${TERRARIA_DIR}/Worlds \
#    banlist=banlist.txt \
#    secure=1 \
#    language=en/US \
#    upnp=1 \
#    npcstream=1 \
#    priority=1
#
#RUN mkdir -p ${TERRARIA_DIR}
#
#WORKDIR ${TERRARIA_DIR}
#
#COPY --from=base ${TERRARIA_DIR}/* ./
#
#RUN chmod +x TerrariaServer.exe
#
#RUN rm System* Mono* monoconfig mscorlib.dll
#
#ENTRYPOINT [ "./init-TerrariaServer-arm64.sh" ]