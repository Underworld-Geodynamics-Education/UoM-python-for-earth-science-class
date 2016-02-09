FROM lmoresi/unimelb-debian-base:v1.03

ENV VERSION=1.03

## ============================================================
## base file has all the labour intensive stuff in it.
## ============================================================



# Change the echo statement to break the cache if the git clone needs refreshing.
RUN  git clone --recursive https://github.com/lmoresi/UoM-python-for-earth-science-class.git /uom_course/ # Watch the cache please !

RUN ls /uom_course

RUN cd /uom_course/NotebookServer && \
    bundle install

RUN cd /uom_course/NotebookServer && \
    ln -s ../NotebookServerContent Content && \
    cp Content/_config.yml _config.yml


RUN   cd /uom_course/NotebookServer &&  _scripts/docker-site-builder


# Make a scratch directory available to connect to the host machine.
# Make the Notebook Resources directory available for extracting outputs etc
# Should not be needed as I put a README there in the repo

# RUN mkdir -p /uom_course/Notebooks/external

VOLUME /uom_course/Notebooks/external
VOLUME /uom_course/Notebooks/Mapping/Resources


# Create a non-privileged user to run the notebooks

RUN useradd --create-home --home-dir /home/serpentine --shell /bin/bash --user-group serpentine
RUN mkdir /uom_course && chown serpentine:serpentine /uom_course

# skip if you need to change things in the live container

USER serpentine
ENV HOME=/uom_course
ENV SHELL=/bin/bash
ENV USER=serpentine
WORKDIR $HOME

# TODO ...
# Ensure the git commit hooks are installed in case people do try to update
# the repo from here !

# Launch the notebook server from the Notebook directory
# The file_to_run option actually does nothing with the no-browser option ...
# but perhaps there is something else that would do this.

WORKDIR /uom_course/Notebooks
EXPOSE 8888
ENTRYPOINT ["/usr/local/bin/tini", "--"]
CMD jupyter notebook --ip=0.0.0.0 --no-browser --NotebookApp.='/tree/StartHere.ipynb'
