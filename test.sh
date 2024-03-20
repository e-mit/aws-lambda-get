#!/bin/bash
set -x #echo on

python -m pytest -s
python -m bandit -r . --exclude=/tests/,/venv/,/package/
python -m pytest --cov=.
python -m flake8 --exclude=tests/*,venv/*,package/*
python -m mypy . --exclude 'tests/' --exclude 'venv/' --exclude 'package/' --explicit-package-bases
python -m pycodestyle function/*.py
python -m pydocstyle function/*.py --ignore=D107,D203,D213
python -m pylint function/*.py
python -m pyright function/*.py
