#!/usr/bin/env bash

# prepare folders
mkdir -p /config/lazylibrarian
mkdir -p /config/lazylibrarian/log
mkdir -p /config/calibre
mkdir -p /config/calibre/tmp
mkdir -p /config/cache/calibre/

# copy default config
if [ ! -f /config/lazylibrarian/config.ini ]; then
    cp -r /defaults/lazylibrarian/config.ini /config/lazylibrarian/config.ini
fi

if [ ! -f /books/metadata.db ]; then
    cp -r /defaults/calibre/metadata.db /books/
fi