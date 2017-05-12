#!/usr/bin/env ruby
BEGIN {$VERBOSE = true}

# This is a utiity to test your connectivity and API access to Flickr.
# You can also use this to do first time caching of credentials for the 
# fetchFlicrPics.rb script.

require 'rubygems'
require 'flickraw'
require 'yaml'
require 'pp'
require 'logger'
require 'thread'

require File.dirname(__FILE__) + '/flickr_logging'
require File.dirname(__FILE__) + '/flickr_raw_auth'
include FlickrAuth

dpf_base_dir = File.expand_path("..", Dir.pwd)

#{}`mkdir -p #{dpf_base_dir}` unless File.exist?(dpf_base_dir)

puts "using or creating token cache in directory = #{dpf_base_dir} "
token_cache_file = "#{dpf_base_dir}/.flickr_token_cache.yml"
pp token_cache_file

config = {}
config = YAML::load(File.open(token_cache_file)) if File.exist?(token_cache_file)    
config[:perms] = 'read' if config[:perms] == nil   

config = validate_flickr_credentials(config)   
if config[:config_changed] == true
  cache_flickr_credentials(token_cache_file, config)
end

pp config
