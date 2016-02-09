FROM lmoresi/unimelb-debian-base:v1.03

ENV VERSION=1.03

## ============================================================
## base file has all the labour intensive stuff in it.
## ============================================================

# Change the echo statement to break the cache if the git clone needs refreshing.

## This should be an ADD or COPY

ADD NotebookServer /uom_course/NotebookServer
ADD CourseContent /uom_course/CourseContent
RUN install_server.sh

## Jekyll Sitebuilder - install gems then build

RUN cd /uom_course/NotebookServer && bundle install &&  _scripts/docker-site-builder

# Make a scratch directory available to connect to the host machine.
# Make the Notebook Resources directory available for extracting outputs etc
# Should not be needed as I put a README there in the repo

# Create a non-privileged user to run the notebooks

# RUN useradd --create-home --home-dir /home/serpentine --shell /bin/bash --user-group serpentine
# RUN chown serpentine:serpentine /uom_course

# skip if you need to change things in the live container

# USER serpentine
# ENV HOME=/uom_course
# ENV SHELL=/bin/bash
# ENV USER=serpentine
# WORKDIR $HOME

# TODO ...
# Ensure the git commit hooks are installed in case people do try to update
# the repo from here !

# RUN mkdir -p /uom_course/Notebooks/external
# VOLUME /uom_course/Notebooks/external
# VOLUME /uom_course/Notebooks/Mapping/Resources


# Launch the notebook server from the Notebook directory
# The file_to_run option actually does nothing with the no-browser option ...
# but perhaps there is something else that would do this.

WORKDIR /uom_course/
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD NotebookServer/_scripts/docker-runservers
