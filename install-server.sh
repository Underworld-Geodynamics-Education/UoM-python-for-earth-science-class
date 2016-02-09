#!/bin/sh

set -e
cd $(dirname "$0")

ln -fs `pwd`/CourseContent  NotebookServer/Content
ln -fs `pwd`/CourseContent/_config.yml NotebookServer/_config.yml
