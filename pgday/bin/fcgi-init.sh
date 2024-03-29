#! /bin/sh
### BEGIN INIT INFO
# Provides:          FastCGI servers for Django
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: Start FastCGI servers with Django.
# Description:       Django, in order to operate with FastCGI, must be started
#                    in a very specific way with manage.py. This must be done
#                    for each DJango web server that has to run.
### END INIT INFO
#
# Author:  Guillermo Fernandez Castellanos
# Version: @(#)fastcgi 0.1 11-Jan-2007 guillermo.fernandez.castellanos AT gmail.com
# Altered by David Reynolds for Debian Stable (http://davidreynolds.me.uk/blog/2007/mar/16/django-fcgi-init-script/)

#### SERVER SPECIFIC CONFIGURATION
export PYTHONPATH=/home/austipug/pgday/public_html
DJANGO_SITES="austinpug"
SITES_PATH=/home/austinpug/pgday/public_html
RUNFILES_PATH=/home/austinpug/pgday/run
HOST=127.0.0.1
PORT_START=3033
RUN_AS=www-data
#### DO NOT CHANGE ANYTHING AFTER THIS LINE!

set -e

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DESC="FastCGI servers"
NAME=$0
SCRIPTNAME=/etc/init.d/$NAME

#
#       Function that starts the daemon/service.
#
d_start()
{
    # Starting all Django FastCGI processes
    PORT=$PORT_START
    for SITE in $DJANGO_SITES
    do
        echo -n ", $SITE"
        if [ -f $RUNFILES_PATH/$SITE.pid ]; then
            echo -n " already running"
        else
            start-stop-daemon --start \
            --exec /usr/bin/python $SITES_PATH/manage.py runfcgi method=threaded \
            host=$HOST port=$PORT pidfile=$RUNFILES_PATH/$SITE.pid --pidfile $RUNFILES_PATH/$SITE.pid
            chmod 400 $RUNFILES_PATH/$SITE.pid
        fi
    done
}

#
#       Function that stops the daemon/service.
#
d_stop() {
    # Killing all Django FastCGI processes running
    for SITE in $DJANGO_SITES
    do
        echo -n ", $SITE"
        start-stop-daemon --stop --quiet --pidfile $RUNFILES_PATH/$SITE.pid \
                          || echo -n " not running"
        if [ -f $RUNFILES_PATH/$SITE.pid ]; then
           rm $RUNFILES_PATH/$SITE.pid
        fi
    done
}

ACTION="$1"
case "$ACTION" in
    start)
        echo -n "Starting $DESC: $NAME"
        d_start
        echo "."
        ;;

    stop)
        echo -n "Stopping $DESC: $NAME"
        d_stop
        echo "."
        ;;

    restart|force-reload)
        echo -n "Restarting $DESC: $NAME"
        d_stop
        sleep 1
        d_start
        echo "."
        ;;

    *)
        echo "Usage: $NAME {start|stop|restart|force-reload}" >&2
        exit 3
        ;;
esac

exit 0
