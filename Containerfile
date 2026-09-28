ARG JAVA_VERSION=13.3
FROM docker.io/gautada/java:${JAVA_VERSION} AS container

LABEL source="https://github.com/gautada/minecraft-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="A container for a minecraft server based on paper"

RUN apt-get update \
 && apt-get install --yes --no-install-recommends screen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /mnt/volumes/container /mnt/volumes/backup 

# WORKDIR /opt
# ADD https://download.java.net/java/early_access/jdk25/7/GPL/openjdk-25-ea+7_linux-aarch64_bin.tar.gz jdk-25.tgz
# RUN /usr/bin/tar zxf jdk-25.tgz \
#  && /usr/bin/mv jdk-25 jdk \
#  && /usr/bin/rm jdk-25.tgz \
#  && /usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
# Rename the base user to this container user.
# Follows the same pattern as other gautada containers.
ARG OLDUSER=duke
ARG USER=steve
RUN /usr/sbin/usermod -l $USER $OLDUSER \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER $OLDUSER \
 && PASSWORD="$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 24)" \
 && printf '%s:%s\n' "$USER" "$PASSWORD" | /usr/sbin/chpasswd

ARG MINECRAFT_VERSION="1.26.3"
WORKDIR /opt/minecraft
ADD https://piston-data.mojang.com/v1/objects/33680f5f2ac32864d6d7cf5e56a705fdb3e05f4c/server.jar minecraft-${MINECRAFT_VERSION}.jar
RUN ln -fsv minecraft-${MINECRAFT_VERSION}.jar minecraft.jar \
 && /usr/bin/chown -R $USER:$USER /opt/minecraft \
 && /usr/bin/chown -R $USER:$USER /mnt/volumes/container \
 && ln -fsv /mnt/volumes/container /home/$USER/server

COPY etc/services.d/minecraft/run /etc/services.d/minecraft/run
RUN chmod +x /etc/services.d/minecraft/run \
 && rm -rf /etc/services.d/java/run

VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/container
EXPOSE 25565/tcp
WORKDIR /home/$USER/server
