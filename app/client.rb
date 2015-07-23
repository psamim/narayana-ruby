$:.unshift(File.dirname(__FILE__))
$stdout.sync = true
require 'rubygems'
require 'data_mapper'
require 'models/chainedtask'
require 'models/nestedtask'
require 'models/calls'
require 'narayana/transaction'
require 'helper/mylogger'
require 'config'

p 'Wait for others to boot'
sleep 20

p 'First scenario, nested transactions'
p 'Creating 7 Tasks'
t1 = NestedTask.create
t2 = NestedTask.create
t3 = NestedTask.create
p 'Task 4 fails'
t4 = NestedTask.create fails: true
t5 = NestedTask.create
t6 = NestedTask.create
t7 = NestedTask.create

p 'Creating nested transactions graph'
t1.subtasks << t2
t1.subtasks << t3
t1.subtasks << t4
t1.subtasks.save

t2.subtasks << t5
t2.subtasks << t6
t2.subtasks.save

t4.subtasks << t7
t2.subtasks.save

p 'Commit nested transaction'
t1.commit

while true
  break if t1.reload.status == :TransactionRolledBack
end
p 'Nested transaction finished'
p "Task 1: #{t1.reload.status}"
p "Task 2: #{t2.reload.status}"
p "Task 3: #{t3.reload.status}"
p "Task 4: #{t4.reload.status}"
p "Task 5: #{t5.reload.status}"
p "Task 6: #{t6.reload.status}"
p "Task 7: #{t7.reload.status}"

p 'Second scenario, chained transactions'
p 'Creating 4 Tasks, number 8 to 11'
t8 = ChainedTask.create
t9 = ChainedTask.create
p 'Task 10 fails'
t10 = ChainedTask.create fails: true
t11 = ChainedTask.create

p 'Creating chains'
t8.next = t9
t8.save
t9.next = t10
t9.save
t10.next = t11
t10.save

p 'Commit chained transaction'
t8.commit

while true
  break if t10.reload.status == :TransactionRolledBack
end

p 'Chaied transaction finished'
p "Task 8: #{t8.reload.status}"
p "Task 9: #{t9.reload.status}"
p "Task 10: #{t10.reload.status}"
p "Task 11: #{t11.reload.status}"

# Prevent client to send exit code
while true
end
