#!/usr/bin/env bash

# Setup some environment vars


# Run jupyter with UV
uv run --python 3.12 jupyter lab --no-browser --sock "${JP_SOCK}" --NotebookApp.token='pw !2345'
