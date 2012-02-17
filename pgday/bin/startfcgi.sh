#!/bin/sh
app_path='/home/autinpug/pgday/public_html'
p='/var/run/lighttpd/django-fastcgi.pid'
cd "$app_path"
if [ -f $p ]; then
    kill $(cat -- $p)
    rm -f -- $p
fi

exec /usr/bin/env \
    PYTHONPATH="$app_path/.." python \
    manage.py runfcgi \
    daemonize=false \
    method=prefork \
    maxspare=2 \
    pidfile="$p"