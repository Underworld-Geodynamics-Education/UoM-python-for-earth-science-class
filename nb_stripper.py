#! /usr/bin/env python

# This is the script that has been installed as the git-commit hook

import sys
import io
import os
import glob
import shutil

from   nbformat import read, write, NO_CONVERT

def remove_outputs(nb):
    """remove the outputs from a notebook"""

    import copy

    nb2 = copy.deepcopy(nb)

    # v3 and v4 differ significantly
    if(nb2["nbformat"] ==3 ):
        for ws in nb2["worksheets"]:
            for cell in ws["cells"]:
                if cell["cell_type"] == 'code':
                    cell.outputs = []
                    prompt_number = 0

    elif (nb2["nbformat"] == 4 ):
            for cell in nb2["cells"]:
                if cell["cell_type"] == 'code':
                    cell["outputs"] = []
                    cell["execution_count"] = None



    return nb2

fails = 0
for file in glob.glob("*.ipynb"):

    try:
        with io.open(file, 'r', encoding='utf8') as f:
            nb = read(f, as_version=NO_CONVERT)

        nb2 = remove_outputs(nb)
        shutil.copy(file, "{}.backup".format(file))
        with io.open("{}".format(file), 'w', encoding='utf8') as f:
             write(nb2, f)
        print 'stripped NB v {} file "{}"'.format(nb.nbformat, file)

    except:
        print "Warning: Notebook {} was not stripped of output data, please check before committing".format(file)
        print "         Over-ride using 'git commit --no-verify' if this warning can be ignored "
        fails += 1

if(fails):
    sys.exit(-1)
