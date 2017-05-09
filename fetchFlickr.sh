#!/usr/bin/env bash

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
