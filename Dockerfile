##
## Use the anaconda image as a base (recommended by cartopy developers)
##

FROM continuumio/anaconda

MAINTAINER Louis Moresi (louis.moresi@unimelb.edu.au)

# Current version of git, please !

RUN apt-get -y update && apt-get -y install git-all

# Add the cartopy installation via anaconda
# Due to issues with shapely 1.5.13 in cartopy 0.13, we
# have to use shapely 1.5.11
# gdal is optional but I need it for image mapping

RUN /opt/conda/bin/conda install -y shapely=1.5.11 && \
    /opt/conda/bin/conda install -y gdal && \
    /opt/conda/bin/conda install -y -c scitools cartopy

## This is a natural point to break the image in two for debugging etc

# Create a non-privileged user to run the notebooks

RUN useradd --create-home --home-dir /home/serpentine --shell /bin/bash --user-group serpentine

# skip if you need to change things in the live container

USER serpentine
ENV HOME=/home/serpentine
ENV SHELL=/bin/bash
ENV USER=serpentine
WORKDIR $HOME

# Grab the latest notebooks - if we use git and don't just copy these in,
# then they can be updated within the container by the default user
# (and if the user has write access to the repo, then it is also possible to
#  update the repo from the container )

RUN git clone https://github.com/lmoresi/UoM-python-for-earth-science-class.git UoM_course

# Ensure the git commit hooks are installed in case people do try to update
# the repo from here !

# TODO ...

# Launch the notebook server from the Notebook directory

WORKDIR UoM_course/Notebooks
ENTRYPOINT ["/usr/bin/tini", "--"]
EXPOSE 8888
CMD jupyter notebook --ip=0.0.0.0 --no-browser
