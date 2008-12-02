#!/usr/bin/env bash

# (The MIT License)
# Copyright (c) 2008 Chris Tirpak <chris@tirpak.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# This script will start or restart the feh
# slideshow for the digital picture frame
#
# Set DISPLAYTIME to number of seconds to display
# each picture for
# so for exmple DISPLAYTIME="300" is 5 minutes
DISPLAYTIME="15"

# Make sure all output goes to the laptops (i.e. DPF) screen
export DISPLAY=:0.0

# Kill any other running versions of feh
killall feh

# Start feh
# feh appears to sort by name/file name
# we reverse it to make files downloaded from flickr 
# appear in reverse chronological order 
# i.e. newest uploads first - which appears to be 
# based on the order you upload pics to flickr
nohup feh --quiet --recursive \
	--full-screen --auto-zoom \
	--reverse --sort name --hide-pointer \
	-D $DISPLAYTIME  ~/FlickrDPF/ &
