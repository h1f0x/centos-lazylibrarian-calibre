#!/usr/bin/env bash

# Restarting Services if dead
systemctl is-active --quiet lazylibrarian.service || systemctl restart lazylibrarian.service