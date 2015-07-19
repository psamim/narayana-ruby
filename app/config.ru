$:.unshift(File.dirname(__FILE__))
$stdout.sync = true

Bundler.require
require 'sinatra/base'
require 'sinatra/synchrony'
require 'rubygems'
require 'bundler'
require 'logger'
require 'data_mapper'
require 'models/task'
require 'models/calls'
require 'service'
require 'helper/mylogger'
require 'config'

configure do
  set :logging, nil
  logger = MyLogger.logger
  set :logger, logger
end

run Service
