#!/bin/sh

set -e
cd $(dirname "$0")

cp -r CourseContent/ NotebookServer/Content/
cp    CourseContent/_config.yml NotebookServer/_config.yml
