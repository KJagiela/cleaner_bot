#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset


python /app/manage.py collectstatic --noinput
python /app/manage.py createsuperuser --noinput

/usr/local/bin/gunicorn config.wsgi --bind 0.0.0.0:8000 --chdir=/app
