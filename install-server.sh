#!/bin/sh

set -e
cd $(dirname "$0")/NotebookServer

ln -s ../CourseContent Content
ln -s Content/_config.yml _config.yml
