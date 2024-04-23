#!/bin/bash

# Validate that we can run checkstyle
# should return 0
checkstyle --help

# Validate that we can run pmd
# FIXME: even help returns a 1, so this is not a good test
#pmd -help
