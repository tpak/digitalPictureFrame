#!/bin/sh
#
# This script will start or restart the feh
# slideshow for the digital picture frame
#
# Set DISPLAYTIME to number of seconds to display
# each picture for
# DISPLAYTIME="300" is 5 minutes
# 
DISPLAYTIME="6"

# Make sure all output goes to the laptops screen
export DISPLAY=:0.0

# Kill any other running versions of feh
killall feh

# Start feh
# feh appears to sort by name/file name
# we reverse it to make files downloaded from flickr 
# appear in reverse chronological order 
# i.e. newest uploads first - and it appears to be 
# based on the order you upload to flickr not the order
# they appear in your sets, sorry
#
# 12-31-2012
# add back --hide-pointer option when ready to ship
# 
# 5-11-2017
# remove --preload option - the way we name files means we dont need it
# and it just burns CPU for a while thinking before starting
nohup feh --quiet --recursive \
	--full-screen --auto-zoom \
	--reverse --sort name --hide-pointer \
	--slideshow-delay $DISPLAYTIME  ~/digitalPictureFrame/Pictures &

