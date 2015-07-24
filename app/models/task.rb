require 'narayana/transaction'

class Task
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :status,
           Enum[ :TransactionActive,
                 :TransactionPrepared,
                 :TransactionCommitted,
                 :TransactionCommittedOnePhase,
                 :TransactionRolledBack
               ],
           default: :TransactionActive
  property :fails, Boolean, default: false
  property :type, Enum[ :Nested, :Chained ], :default => lambda { |resource, property| resource.type }

  # Resource URL to give to TX manager
  def url
    "http://#{Config::APP_HOST}:#{Config::APP_PORT}/task/#{self.id}"
  end

  def txStatus(txStatus)
    p "TaskModel: Setting status #{txStatus} for task #{self.id}"

    if [:TransactionCommitted, :TransactionCommittedOnePhase].include? txStatus then
      p "TaskModel: Task #{self.id}, Type: #{self.type}, trying to commit"
      return self.commit
    elsif :TransactionPrepared == txStatus then
      p "TaskModel: Task #{self.id}, Type: #{self.type}, trying to prepare"
      return self.prepare
    elsif :TransactionRolledBack == txStatus then
      return self.rollback
    end

    return false
  end

  def Task.getWithType(id)
    task = self.get(id)
    task = ChainedTask.get(id) if task.type == :Chained
    task = NestedTask.get(id) if task.type == :Nested
    return task
  end
end
