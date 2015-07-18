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
  property :fails, Boolean, default: true

  def url
    "http://#{Config::APP_HOST}:#{Config::APP_PORT}/task/#{self.id}"
  end

  def status=(newStatus)
    MyLogger.info "TaskModel: Setting status #{newStatus} for task #{self.id}"

    if self.tasks.empty?
      MyLogger.info "TaskModel: Task #{self.id}, no sub-tasks."
      return self.attribute_set(:status, newStatus) 
    end

    tasksBeforeCommit = self.tasks.count
    committedTasks =
      self.tasks.all(status: :TransactionCommitted).count +
      self.tasks.all(status: :TransactionCommittedOnePhase).count

    if committedTasks == tasksBeforeCommit
      MyLogger.info "Task #{self.id}: All sub-tasks were committed before."
      return self.attribute_set(:status, newStatus)
    end

    # Commit all sub tasks in a transaction
    tx = Transaction.new
    self.tasks.each do |t|
      tx.participate t.url
    end
    tx.commit

    # Wait until all sub-tasks are committed or return false
    counter = 0
    while committedTasks != tasksBeforeCommit
      MyLogger.info "Task #{self.id}: Waiting for sub-tasks to commit."
      sleep 0.5
      counter +=1
      committedTasks =
        self.tasks.all(status: :TransactionCommitted).count +
        self.tasks.all(status: :TransactionCommittedOnePhase).count
      if counter == 10
        MyLogger.info "Task #{self.id}: Sub-tasks did not commit in #{counter*0.5} seconds, aborting."
        return false
      end
    end

    MyLogger.info "Task #{self.id}: sub-tasks committed successfully"
    return self.attribute_set(:status, newStatus)
  end

    def commit
      self.status = :TransactionCommitted
    end
    
    def commitSubTasks
    end
end
