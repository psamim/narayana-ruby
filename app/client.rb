$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'data_mapper'
require 'models/task'
require 'narayana/transaction'
require 'config'


tx = Transaction.new

t = Task.create name: 'Task One'
tx.participate t.url

t = Task.create name: 'Task Two'
tx.participate t.url

tx.commit
