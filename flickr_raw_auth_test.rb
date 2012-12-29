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