FROM ubuntu:bionic

RUN apt-get update
RUN apt-get install -y cpufrequtils indicator-cpufreq cpuset
RUN apt-get install -y openjdk-8-jdk maven

WORKDIR compare

ADD . /compare