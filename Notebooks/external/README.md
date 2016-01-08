## `external`

This folder is the mount point for external volumes in the docker container.
When you mount a data volume it will replace the this file !

If you wish to use this setup to work on your own notebooks then you should
follow the [instructions](https://docs.docker.com/engine/userguide/dockervolumes/)
on how to mount an external directory to a container

`$ docker run -d -P --name UoM -v /my/local/notebooks:/home/serpentine/UoM_course/Notebooks/external lmoresi/uom... `

Or, if you use kitematic, point the external volume to your notebooks.

If you just want to work on your own copy of the data with the example notebooks, then you should
mount your directory as the Resources volume. 
