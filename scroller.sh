#!/bin/bash

# Name of your polybar bar, which will
# run this script. The default bar is
# named "example".
BAR="example"

# Set the name of the module, which
# contains the play/pause button.
# The module should be located in the
# bar that is defined above this.
# Leave blank to disable play/pause
# button functionality.
MODULE="spotify-play-pause"

# Set the name of desired mpris player,
# such as firefox, spotify, chromium,
# vlc or simply just playerctl.
PLAYER="spotify"

# Set delay (in seconds) between rotating 
# a single character of text (lower
# number correspons to faster scrolling).
DELAY="0.2"

# Set the maximum length of the text.
# If the text is longer than LENGTH,
# it will rotate, otherwise it will not.
LENGTH="25"

# If force is set to "1", the text
# will rotate, even if it is not
# too long.
FORCE="0"

# Set a separator for the text.
# If the text should rotate, then
# this string will be appended to
# the end of the text.
SEPARATOR=""

# Set text between the artist and
# title texts.
MIDDLE=" - "

# The text will be updated every INTERVAL
# rotations, i. e. if DELAY is set to 0.2
# and INTERVAL is set to 5, then the
# status and text will be updated every
# 0.2 * 5 = 1 second(s). This is mainly
# meant to reduce an unnecessary high
# number of dbus requests and minimize
# resource usage.
INTERVAL="5"

### END OF USER CONFIGURATION ###

GETPLAYER="dbus-send --print-reply \
--dest=org.freedesktop.DBus \
/org/freedesktop/DBus \
org.freedesktop.DBus.ListNames \
| grep mpris \
| grep $PLAYER \
| sed 's/.*string \"//g;s/.$//g'"

DEST=$(eval $GETPLAYER)
# echo $DEST

ARTISTCOMMAND="dbus-send --print-reply \
--dest="$DEST" \
/org/mpris/MediaPlayer2 \
org.freedesktop.DBus.Properties.Get \
string:"org.mpris.MediaPlayer2.Player" \
string:"Metadata" \
| grep -A 2 'artist' \
| tail -1 \
| sed 's/.*string \"//g;s/.$//g'"

TITLECOMMAND="dbus-send --print-reply \
--dest="$DEST" \
/org/mpris/MediaPlayer2 \
org.freedesktop.DBus.Properties.Get \
string:"org.mpris.MediaPlayer2.Player" \
string:"Metadata" \
| grep -A 1 'title' \
| tail -1 \
| sed 's/.*string \"//g;s/.$//g'"

# echo $ARTISTCOMMAND
# echo $TITLECOMMAND

# ARTIST=$(eval $ARTISTCOMMAND)
# TITLE=$(eval $TITLECOMMAND)

# echo $ARTIST
# echo $TITLE

STATUSCOMMAND="dbus-send --print-reply \
--dest="$DEST" \
/org/mpris/MediaPlayer2 \
org.freedesktop.DBus.Properties.Get \
string:org.mpris.MediaPlayer2.Player \
string:PlaybackStatus \
| grep variant \
| sed 's/.*string \"//g;s/.$//g'"

# STATUS=$(eval $STATUSCOMMAND)
# echo $STATUS

PID=$(pgrep -a "polybar" | grep "$BAR" | cut -d" " -f1)

# [[ $FORCE = 0 ]] && echo "Zero" || echo "One"

./playerctl-scroller \
-l $LENGTH \
-d $DELAY -u $INTERVAL \
-t "$STATUSCOMMAND" \
-p $PID \
-m "$MODULE" \
-c "$ARTISTCOMMAND" "$MIDDLE" -c "$TITLECOMMAND" \
-s "$SEPARATOR"