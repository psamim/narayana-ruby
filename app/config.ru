$:.unshift(File.dirname(__FILE__))

Bundler.require
require 'config'
require 'sinatra'
require 'rubygems'
require 'bundler'
require 'logger'
require 'data_mapper'
require 'models/task'
require 'service'

run Service
