#!/bin/sh
#
# This script will start or restart the feh
# slideshow for the digital picture frame
#
# Set DISPLAYTIME to number of seconds to display
# each picture for
# DISPLAYTIME="300" is 5 minutes
DISPLAYTIME="15"

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
# add back --hide-pointer when ready to ship
#
nohup feh --quiet --recursive --preload \
	--full-screen --auto-zoom \
	--reverse --sort name --hide-pointer \
	-D $DISPLAYTIME  ~/FlickrDPF &

