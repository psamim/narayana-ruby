$:.unshift(File.dirname(__FILE__))
$stdout.sync = true
require 'rubygems'
require 'data_mapper'
require 'models/task'
require 'models/calls'
require 'narayana/transaction'
require 'config'
require 'helper/mylogger'

# Wait for others to boot
sleep 20

# First scenario, nested transactions
# Create Tasks
t1 = Task.create type: :Nested
t2 = Task.create type: :Nested
t3 = Task.create type: :Nested
t4 = Task.create type: :Nested, fails: true
t5 = Task.create type: :Nested
t6 = Task.create type: :Nested
t7 = Task.create

t1.subtasks << t2
t1.subtasks << t3
t1.subtasks << t4
t1.subtasks.save

t2.subtasks << t5
t2.subtasks << t6
t2.subtasks.save

t4.subtasks << t7
t2.subtasks.save

t1.commit

sleep 5

# Second scenario, chained transactions
t1 = Task.create type: :Chained
t2 = Task.create type: :Chained
t3 = Task.create type: :Chained, fails: true
t4 = Task.create

t1.next = t2
t1.save
t2.next = t3
t2.save
t3.next = t4
t3.save

t1.commit

# Prevent client to send exit code
while true
end
