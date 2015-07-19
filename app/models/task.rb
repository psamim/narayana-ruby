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

  def url
    "http://#{Config::APP_HOST}:#{Config::APP_PORT}/task/#{self.id}"
  end

  def txStatus(txStatus)
    MyLogger.info "TaskModel: Setting status #{txStatus} for task #{self.id}"

    if [:TransactionCommitted, :TransactionCommittedOnePhase, :TransactionPrepared].include? txStatus then
      return self.commit
    elsif :TransactionRolledBack == txStatus then
      return self.rollback
    end

    return false
  end

  def commit
    MyLogger.info "TaskModel: Task #{self.id}, trying to commit"

    if self.fails
      MyLogger.warn "TaskModel: Task #{self.id}, Task failed."
      return false
    elsif self.commitSubTasks
      self.update status: :TransactionCommitted
      MyLogger.info "TaskModel: Task #{self.id}, committed successfully"
      return true
    else
      MyLogger.warn "TaskModel: Task #{self.id}, commit failed."
      self.rollback
      return false
    end
  end

  def rollback
    MyLogger.info "TaskModel: Task #{self.id}, trying to rollback all subtasks"
    self.update status: :TransactionRolledBack
    self.subtasks.all.update status: :TransactionRolledBack
    return true
  end

  def commitSubTasks
    if self.subtasks.empty?
      MyLogger.info "TaskModel: Task #{self.id}, has no sub-tasks."
      return true
    end

    tasksBeforeCommit = self.subtasks.count
    committedTasks =
      self.subtasks.all(status: :TransactionCommitted).count +
      self.subtasks.all(status: :TransactionCommittedOnePhase).count

    if committedTasks == tasksBeforeCommit
      MyLogger.info "TaskModel: Task #{self.id}: All sub-tasks were committed before."
      return true
    end

    # Commit all sub tasks in a transaction
    tx = Transaction.new
    self.subtasks.each do |t|
      tx.participate t.url
    end
    tx.commit

    # Wait until all sub-tasks are committed or return false
    counter = 0
    while committedTasks != tasksBeforeCommit
      MyLogger.info "TaskModel: Task #{self.id}: Waiting for sub-tasks to commit."
      sleep 1
      counter +=1
      committedTasks =
        self.subtasks.all(status: :TransactionCommitted).count +
        self.subtasks.all(status: :TransactionCommittedOnePhase).count
      if counter == 10
        MyLogger.warn "TaskModel: #{self.id}: Sub-tasks did not commit in #{counter*0.5} seconds, aborting."
        return false
      end
    end

    MyLogger.info "TaskModel: Task #{self.id}: sub-tasks committed successfully"
    return true
  end
end
