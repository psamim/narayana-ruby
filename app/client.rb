$:.unshift(File.dirname(__FILE__))
$stdout.sync = true
require 'rubygems'
require 'data_mapper'
require 'models/task'
require 'models/calls'
require 'narayana/transaction'
require 'globalconf'
require 'helper/mylogger'

# Wait for others to boot
sleep 15

# Create Tasks
t1 = Task.create
t2 = Task.create
t3 = Task.create
t4 = Task.create
t5 = Task.create
t6 = Task.create
t7 = Task.create

# Create Nested Transactions
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

# Prevent client to send exit code
while true
end
