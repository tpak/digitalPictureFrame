#!/usr/bin/env ruby
BEGIN {$VERBOSE = true}

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


# http://blog.irisquest.net/2007/06/flickr-photo-collage-ruby
#

require 'rubygems'
require 'flickraw' 
require 'open-uri'
require 'optparse'
require 'pp'      
require 'logger'
require 'thread'

require File.dirname(__FILE__) + '/flickr_logging'
require File.dirname(__FILE__) + '/flickr_raw_auth'

class FlickrPictureFetcher

  include FlickrAuth 
  
  #
  # program options
  #
  def getopts(args)
    begin
      opts = OptionParser.new                  
      options = {}
  
      opts.on("-d", "--directory DIRECTORY",
        "Directory to store downloaded pictures and credentials cache in. " + \
        "The Default is $HOME/FlickrDPF of the invoking user", String) do |dir|
        options[:directory] = dir
      end     
      opts.on("--debug", "Set logging level to debug") do
        options[:debug] = true
        log.level = Logger::DEBUG
        log.debug('log level now set to DEBUG')
        log.debug{"log.level = #{log.level}"}
      end
      opts.on("-g", "--getfaves", "Get favorites for username specified") do
        options[:getfaves] = true
      end
      opts.on("-h", "-?", "--about", "--help", "Show help") do
        puts opts.to_s    
        exit
      end
      opts.on("-m", "--maxphotos MAX",
        "Maximum photos to fetch for this user, default is 1.", Integer) do |mp|
        options[:maxphotos] = mp
      end
      opts.on("-t", "--tags TAGS",
        "Fetch only photos tagged with tag(s). Seperate tags with a comma.", String) do |t|
        options[:tags] = t
      end     
      opts.on("-u", "--username USERNAME", 
        "Flickr username to retrives pics from.", String) do |usr| 
          options[:username] =  usr
      end     
       
      opts.parse!(args)
    rescue Exception => ex
      log.error{ex}
      exit
    end
    return options    
  end                      

  #
  # Obtain the the list of photos from Flickr.
  #
  def get_photo_list(config, options)
    begin
        log.debug{"inside #{get_method}"}
        remaining_photos = options[:maxphotos]
        fetched_photos = 0
        available_photos = 1
        on_page = 0
        complete_photo_list = Array.new     

        #fetch all the photos at once unless the requested number is greater than
        #the limit set by flicker - if so we will make multiple 'page' calls to flickr 
        per_page_photo_count = options[:maxphotos] > FLICKR_PER_PAGE_LIMIT ? FLICKR_PER_PAGE_LIMIT : options[:maxphotos]

        # find the real flickr user identifier not their username
        # use the one specified on the command line options not in 
        # the credentials, they can be the same but don't need to be
        log.debug('checking the user name')
        if !options[:getfaves]
          flickr_user = flickr.people.findByUsername( :username => options[:username] ) 
          # override options username b/c flickr may have differnet case rules but finds it
          # we need it for cleaning up files later on
          options[:username] = flickr_user.username
        end

        #don't get any more photos than the user asked for or try to get more than are available
        #we assume that there is at least one to allow the loop to run the first time and avoid
        #extra calls to flickr
        log.debug('getting the photo list')
        while fetched_photos < options[:maxphotos] && available_photos > fetched_photos
          on_page += 1
          if options[:getfaves] == true
            photo_list = flickr.favorites.getList(:api_key => config[:api_key], :token => config[:oauth_access_token], \
              :user_id => config[:nsid], :page => on_page, :per_page => per_page_photo_count, \
              :sort => 'date-posted-desc', :extras => "date_upload,date_taken,owner_name" )
          else
            photo_list = flickr.photos.search(:api_key => config[:api_key], :sort => 'date-posted-desc', \
              :user_id => flickr_user.nsid, :page => on_page, :per_page => per_page_photo_count, \
              :tags => options[:tags], :extras => "date_upload,date_taken,owner_name" )
          end
          log.debug{'have the photo list now'}
          log.debug{"photo list = "}
          log.debug{photo_list.marshal_dump}
          
          # Array.count must be new in ruby 1.8.7? fails on 1.8.6 ....
          # so I changed the following line to be 1.8.6 compatible
          #fetched_photos += photo_list.count
          fetched_photos += photo_list.length
          available_photos = photo_list.total.to_i
          remaining_photos = (options[:maxphotos] - fetched_photos)

          #combine the fetched results into one big list to hand back
          #FlickRaw::ResponseList
          #http://hanklords.github.com/flickraw/FlickRaw/ResponseList.html
          #for some reason ResponseList does not show up in the object index of rdoc on GitHub 
          #as of this writing 12/24/2012
          complete_photo_list += photo_list.to_a      
          
          #reset the per_page_photo_count if we only need a partial page
          #as per above, per_page_photo count is set to the max allowed by
          #flickr - as long as that is greater than the remaining photos we
          #stick with it - this keeps the number of calls to flickr to the minimum 
          per_page_photo_count = remaining_photos > per_page_photo_count ? per_page_photo_count : remaining_photos

        end
    rescue Exception => ex
      log.info(ex)
      exit
    end
    
    log.debug{"complete photo list"}
    log.debug{complete_photo_list}
    log.debug{"exiting #{get_method}"}
    return complete_photo_list, options
  end

  #
  # Get the url for the photo. We call the Flickr getSizes to see
  # what is available and then pick the largest one 
  #
  def get_photo_url (photo)
    begin
      log.debug{"inside #{get_method}"}
      photo_sizes = flickr.photos.getSizes(:photo_id => photo.id)   
      pic_url = nil
      #max_size_label = nil                               
      max_dimension = 0
      photo_sizes.each {|x|
          if max_dimension <= x.width.to_i || max_dimension <= x.height.to_i
            #max_size_label = x.label   
            pic_url = x.source
            max_dimension = max_dimension > x.width.to_i ? max_dimension : x.width.to_i
            max_dimension = max_dimension > x.height.to_i ? max_dimension : x.height.to_i
          end      
        }
      # Get rid of white space in url. flickraw somehow gets a single whitespace after
      # the "http://" - weird    
      pic_url = pic_url.sub(/ /, '').strip
    rescue Exception => ex
      log.error{ex}
      exit
    end
    return pic_url
  end

  #
  # Construct the filename using some metadata
  #
  def photo_filename (options, photo, photo_url)
    begin
      log.debug{"inside #{get_method}"}
      # date upload is passed around as a unix timestamp
      uploaded = Time.at(photo.dateupload.to_i).strftime("%Y%m%d%H%M%S")

      # date taken is passed around as mySQL 'datetime' format
      taken = DateTime.parse(photo.datetaken).strftime("%Y%m%d%H%M%S")


      # parse photo url and get path which is comprised of the 
      # flickr server number, phot id, and photo secret and type
      # where type will be jpg, gif, or png
      # we'll keep this stuff mostly intact so we have some remote chance 
      # of troubleshooting later 
      photo_uri = URI.parse(photo_url)
    
      # strip slashes out of the path and turn them to dashes for use in file name
      photo_path = photo_uri.path.gsub(/\//,'-')

      # make the filename logicly sortable by upload date, taken date, owner,
      # and flickr picture id
      # this will help a viewer such as feh sort most recently found pics
      # for more than one user - hey, my mom has a couple of kids that use flickr
      # usualy a bad idea to put intelligence in file names but i am doing it anyway
      if options[:getfaves] == true
        filename = "#{options[:directory]}/u-#{uploaded}-t-#{taken}-#{photo.ownername}.favorite#{photo_path}"
      else
        filename = "#{options[:directory]}/u-#{uploaded}-t-#{taken}-#{photo.ownername}#{photo_path}"
      end
    rescue Exception => ex
      log.error{ex}
      exit
    end
    return filename
  end 

  # Download all the photos in the list we just created
  def download_photos(config, options, photo_list)
    begin
      log.debug{"inside #{get_method}"}
      files = []
      skipcount = 0
      fetchcount = 0 
      photo_list.each do |photo|
        photo_url = get_photo_url(photo)
        fileName = photo_filename(options, photo, photo_url)
        if !File.exists?(fileName)
          log.info{"Fetching #{photo_url.to_s}"}
          open photo_url do |remote|
            open(fileName, 'wb') { |local| local << remote.read }
          fetchcount += 1
          end
          else
            log.debug{"Skipping duplicate #{photo_url.to_s}"}
            skipcount += 1
          end
         files << fileName
        end
    rescue Exception => ex
      log.error{ex}
      exit
    end
    log.info{"fetched #{fetchcount} new pictures"}
    log.info{"skipped #{skipcount} duplicate pictures"}
    return files
  end

  # get rid of old files
  def cleanup(options, keep_these_files)
    begin
      log.debug{"inside #{get_method}"}
      # if you need to debug, you might want to sort the file list for easier reading
      log.debug{"keep these files = #{keep_these_files.sort!.reverse!}"}
      #p keep_these_files
    
      # get a list of all the files we have, names are slightly different depending
      # on if they are faves or not
      if options[:getfaves] == true
        all_files = Dir.glob("#{options[:directory]}/*{.favorite}*.{png,jpg,gif}")
      else
        all_files = Dir.glob("#{options[:directory]}/*#{options[:username]}-*.{png,jpg,gif}")
      end
    
      # diff the two sets
      remove_these_files = all_files - keep_these_files
      log.debug{"removing these files = #{remove_these_files}"}
    
      # delete the unwanted files
      remove_these_files.each {|f| File.delete(f)}
    rescue Exception => ex
      log.error{ex}
      exit
    end
  end

end

#

log.level = Logger::INFO
log.info{"#{$0} starting with options: #{ARGV}"}

fetcher = FlickrPictureFetcher.new

options = fetcher.getopts(ARGV)
log.debug{'command line options ='}
log.debug{options}

# set default options if otherwise not specified by the user              
options[:directory] = File.expand_path '~/FlickrDPF' if options[:directory] == nil  
options[:maxphotos] = 1 if options[:maxphotos] == nil || options[:maxphotos] <= 0
log.info{'running with options ='}
log.info{options}

# if our photo and credentials cache storage directory doesn't exist, create it 
`mkdir -p #{options[:directory]}` unless File.exist?(options[:directory])
token_cache_file = "#{options[:directory]}/.flickr-token-cache.yml"

# get credentials config - this is different than the options because it is persistent across
# invocations of the utility, we can fetch different users pictures but we need credentials
# to do that with - and we can store those across invocations of this utility
config = {}
config = YAML::load(File.open(token_cache_file)) if File.exists?(token_cache_file)    
config[:perms] = 'read' if config[:perms] == nil   

config = fetcher.validate_flickr_credentials(config)   
if config[:config_changed] == true
  fetcher.cache_flickr_credentials(token_cache_file, config)
end
#pp config if options[:debug] == true
log.debug{"config file dump"}
log.debug{config}
        
# OK, now we can get the work done - get a list of photos and then retrieve them if
# they are not already on the computer.
FLICKR_PER_PAGE_LIMIT = 500
photo_list, options = fetcher.get_photo_list(config, options)        
files = fetcher.download_photos(config, options, photo_list)
fetcher.cleanup(options, files)

log.info{"#{$0} exiting"}
exit
