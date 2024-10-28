#!/bin/bash

url=$(wl-paste)
notify-send "fetching video: ${url}"
mpv --really-quiet $url > /dev/null 2>&1 &
