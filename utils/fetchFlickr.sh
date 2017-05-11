#!/usr/bin/env bash

#
# run fetchFlickrPics.rb 

FLICKRLOGFILE="~/digitalPictureFrame/log/fetchFlickrPics.log"

#remove the old log file on every run
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

# send the log in an email 
cat $FLICKRLOGFILE | /usr/bin/mailx -s "$SUBJECT" "$EMAIL" 