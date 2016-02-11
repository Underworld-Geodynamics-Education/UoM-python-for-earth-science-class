FROM lmoresi/unimelb-debian-base:v1.03

ENV VERSION=1.03

## ============================================================
## base file has all the labour intensive stuff in it.
## ============================================================

# Change the echo statement to break the cache if the git clone needs refreshing.

## This should be an ADD or COPY

ADD NotebookServer /uom_course/NotebookServer
ADD CourseContent /uom_course/CourseContent
ADD install-server.sh /uom_course/install-server.sh
RUN /uom_course/install-server.sh

## Jekyll Sitebuilder - install gems then build

RUN cd /uom_course/NotebookServer && bundle install &&  _scripts/docker-site-builder

# Make a scratch directory available to connect to the host machine.
VOLUME /uom_course/NotebookServer/_site/Content/Notebooks/external

# Create a non-privileged user to run the notebooks

RUN useradd --create-home --home-dir /home/serpentine --shell /bin/bash --user-group serpentine
RUN chown -R serpentine:serpentine /uom_course

# skip if you need to change things in the live container

USER serpentine
ENV HOME=/uom_course
ENV SHELL=/bin/bash
ENV USER=serpentine
WORKDIR $HOME

# Launch the notebook server from the Notebook directory
# The file_to_run option actually does nothing with the no-browser option ...
# but perhaps there is something else that would do this.

WORKDIR /uom_course/
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD NotebookServer/_scripts/docker-runservers
