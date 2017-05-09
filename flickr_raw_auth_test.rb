#!/usr/bin/env ruby
BEGIN {$VERBOSE = true}

# This is a utiity to test your connectivity and API access to Flickr.
# You can also use this to do first time caching of credentials for the 
# fetchFlicrPics.rb script.

require 'rubygems'
require 'flickraw'
require 'yaml'
require 'pp'

require File.dirname(__FILE__) + '/flickr_raw_auth'
include FlickrAuth

dpf_dir = File.expand_path '~/FlickrDPF'
`mkdir -p #{dpf_dir}` unless File.exist?(dpf_dir)
puts "using cache from directory = #{dpf_dir} "
token_cache_file = "#{dpf_dir}/.flickr-token-cache.yml"

config = {}
config = YAML::load(File.open(token_cache_file)) if File.exists?(token_cache_file)    
config[:perms] = 'read' if config[:perms] == nil   

config = validate_flickr_credentials(config)   
if config[:config_changed] == true
  cache_flickr_credentials(token_cache_file, config)
end

pp config

list   = flickr.photos.getRecent
pp list