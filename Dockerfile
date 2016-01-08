FROM debian:latest

MAINTAINER Louis Moresi

## the update is fine but very slow ... keep it separated so it doesn't
## get run every time !

RUN apt-get update -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        git \
        python \
        python-dev \
        python-pip \
        ssh \
        curl \
        libgl1-mesa-dri \
        libgl1-mesa-glx \
        rsync \
        vim \
        less \
        xauth \
        swig

## These are for the full python - scipy stack

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libopenblas-dev \
    liblapack-dev \
    libscalapack-mpi-dev \
    libhdf5-serial-dev \
    libnetcdf-dev \
    gfortran \
    cython \
    libfreetype6-dev \
    python-numpy \
    python-scipy \
    python-matplotlib \
    python-pandas \
    python-sympy \
    python-nose \
    pkg-config

# Better to build the latest versions than use the old apt-gotten ones
# I'm putting this here as it takes time and ought to be cached before the
# more ephemeral parts of this image.

RUN pip install matplotlib numpy scipy --upgrade

#
# These ones are needed for cartopy / imaging / geometry stuff
#

# (proj4 is buggered up everywhere in apt-get ... so build a known-to-work version from source)
#
RUN cd /usr/local && \
    curl http://download.osgeo.org/proj/proj-4.8.0.tar.gz > proj-4.8.0.tar.gz && \
    tar -xzf proj-4.8.0.tar.gz && \
    cd proj-4.8.0 && \
    ./configure && \
    make all && \
    make install

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python-gdal \
        python-pil  \
        python-h5py \
        libxml2-dev \
        python-lxml \
        libgeos-dev

## The recent netcdf4 / pythonlibrary stuff doesn't work properly with the default search paths etc
## here is a fix which builds the repo version. Hoping that pip install or apt-get install will work again soon

RUN USE_SETUPCFG=0 HDF5_INCDIR=/usr/include/hdf5/serial HDF5_LIBDIR=/usr/lib/x86_64-linux-gnu/hdf5/serial pip install --user git+https://github.com/Unidata/netcdf4-python

RUN pip install \
            runipy \
            ipython \
            shapely==1.5.12 \
            cartopy \
            obspy \
            jupyter

## ==============================================================

# Add Tini
ENV TINI_VERSION v0.8.4
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
# ENTRYPOINT ["/tini", "--"]


## ============================================================
##
##

# Create a non-privileged user to run the notebooks

RUN useradd --create-home --home-dir /home/serpentine --shell /bin/bash --user-group serpentine

# skip if you need to change things in the live container

# USER serpentine
ENV HOME=/home/serpentine
ENV SHELL=/bin/bash
# ENV USER=serpentine
# WORKDIR $HOME


RUN git clone https://github.com/lmoresi/UoM-python-for-earth-science-class.git UoM_course

# Ensure the git commit hooks are installed in case people do try to update
# the repo from here !

# TODO ...

# Launch the notebook server from the Notebook directory

WORKDIR UoM_course/Notebooks
EXPOSE 8888
CMD jupyter notebook --ip=0.0.0.0 --no-browser
