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

DataMapper.setup :default, "sqlite3://#{Dir.pwd}/db.db"
DataMapper.finalize
Task.auto_migrate!

run Service
