FROM phusion/baseimage:0.9.22
# ubuntu 1604 LTS inside

# declare a default value for the LI3DS API key
ENV API_KEY 4c822795-c507-439a-9ea4-525237045427

# Install postgresql
RUN apt-get update -y
RUN apt-get install -y \
  postgresql-server-dev-9.5 \
  postgis \
  postgresql-9.5-postgis-2.2 \
  postgresql-plpython3-9.5

RUN echo "host   all  all  0.0.0.0/0 md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "local  all  all            md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'"           >> /etc/postgresql/9.5/main/postgresql.conf

# Install Python 2.7 and Python 3.5
RUN apt-get install -y --no-install-recommends \
        python2.7 \
        python2.7-dev \
        python-pip \
        python-setuptools \
        python-numpy \
        python3.5 \
        python3.5-dev \
        python3-pip \
        python3-setuptools \
        python3-numpy \
        python-rosbag \
        python-genmsg \
        python-genpy \
        python-rosgraph \
        python-rosgraph-msgs \
        git \
        make \
        build-essential \
        autoconf \
        automake \
        libxml2-dev \
        graphviz \
        zlib1g-dev \
    && pip install --upgrade pip \
    && pip3 install --upgrade pip

# Install pg_pointcloud
RUN git clone https://github.com/LI3DS/pointcloud.git
RUN cd pointcloud && ./autogen.sh && ./configure && make -j3 && make install

# Install pg-li3ds
RUN git clone https://github.com/li3ds/pg-li3ds
RUN cd pg-li3ds && make install

# Install fdw-li3ds
RUN git clone https://github.com/Kozea/Multicorn && \
    cd Multicorn && \
    PYTHON_OVERRIDE=python2 make -j3 && \
    PYTHON_OVERRIDE=python2 make install && \
    cd .. && \
    git clone https://github.com/LI3DS/fdw-li3ds && \
    cd fdw-li3ds && \
    pip2 install -e .


# Install cli-li3ds
RUN git clone https://github.com/li3ds/cli-li3ds.git
RUN cd cli-li3ds && pip3 install -e .

# Create li3ds user and database
USER postgres
RUN /etc/init.d/postgresql start && \
  psql --command "CREATE USER li3ds WITH SUPERUSER PASSWORD 'li3ds'" && \
  createdb -O li3ds li3ds && \
  psql -d li3ds --command "create extension plpython3u" && \
  psql -d li3ds --command "create extension postgis" && \
  psql -d li3ds --command "create extension pointcloud" && \
  psql -d li3ds --command "create extension pointcloud_postgis" && \
  psql -d li3ds --command "create extension li3ds" && \
  psql -d li3ds --command "create extension multicorn" && \
  psql -d li3ds --command "create server echopulse foreign data wrapper multicorn options ( wrapper 'fdwli3ds.EchoPulse' )" && \
  psql -d li3ds --command "create server sbet foreign data wrapper multicorn options ( wrapper 'fdwli3ds.Sbet' )" && \
  /etc/init.d/postgresql stop
USER root

# Install api-li3ds
RUN git clone https://github.com/li3ds/api-li3ds.git
RUN cd api-li3ds && pip3 install -e .
# Install conf for api-li3ds
ADD conf/api_li3ds.yml api-li3ds/conf/


ENV HOME /scripts
WORKDIR /scripts

# Add daemon to be run by runit.
# Adding startup scripts
ADD start_pg.sh /scripts/
RUN mkdir /etc/service/postgresql
RUN ln -s /scripts/start_pg.sh /etc/service/postgresql/run

ADD start_api.sh /scripts/
RUN mkdir /etc/service/api-li3ds
RUN ln -s /scripts/start_api.sh /etc/service/api-li3ds/run

# Expose postgres and api ports
EXPOSE 5432
EXPOSE 5000

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
