$:.unshift(File.dirname(__FILE__))
require 'config'
require 'rubygems'
require 'data_mapper'
require 'models/task'
require 'narayana/transaction'

DataMapper.setup :default, "sqlite3://#{Dir.pwd}/db.db"
DataMapper.finalize
Task.auto_migrate!

tx = Transaction.new
t1 = Task.create name: 'Task One'
tx.participate t1.url
