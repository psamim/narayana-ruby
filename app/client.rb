$:.unshift(File.dirname(__FILE__))
require 'rubygems'
require 'data_mapper'
require 'models/task'
require 'narayana/transaction'
require 'config'

sleep 30

tx = Transaction.new

t1 = Task.create name: 'Task One'
tx.participate t1.url

t2 = Task.create name: 'Task Two'
tx.participate t2.url

tx.commit

while true
end
