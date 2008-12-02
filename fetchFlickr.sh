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
#
# run fetchFlickr.rb 

FLICKRLOGFILE="/home/dpfuser/bin/fetchFlickr.log"

#remove the old log file -- uncomment this if you want it removed
#rm $FLICKRLOGFILE

echo "Starting fetchFlickrPics at: " >> $FLICKRLOGFILE
date >> $FLICKRLOGFILE

RUBYLIB=~/bin
export RUBYLIB

/home/dpfuser/bin/fetchFlickrPics.rb -g -m15 >> $FLICKRLOGFILE 2>&1
/home/dpfuser/bin/fetchFlickrPics.rb -u mom -t cats,thekids -m 15 >> $FLICKRLOGFILE 2>&1
/home/dpfuser/bin/fetchFlickrPics.rb -u sue -t 4bob -m 15 >> $FLICKRLOGFILE 2>&1
/home/dpfuser/bin/fetchFlickrPics.rb -u dave -t 4bob -m 15 >> $FLICKRLOGFILE 2>&1

echo "End  fetchFlickrPics at: " >> $FLICKRLOGFILE
date >> $FLICKRLOGFILE
