#IRIS
FROM containers.intersystems.com/intersystems/irishealth-community:2024.2
USER irisowner

WORKDIR /dur
COPY --chown=irisowner:irisowner --chmod=700 src /dur


RUN find . -name '.DS_Store' -type f -delete

USER root
RUN apt -y remove temurin-8-jdk*
RUN apt update
RUN apt install -y openjdk-11-jdk

USER irisowner
RUN iris start $ISC_PACKAGE_INSTANCENAME &&\
/dur/init/init.sh 




