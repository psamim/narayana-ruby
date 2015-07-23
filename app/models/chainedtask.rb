require 'models/task'

class ChainedTask < Task
  def type
    :Chained
  end

  def commit
    if self.fails
      MyLogger.warn "TaskModel: Task #{self.id}, Task failed."
      self.rollback
      return false
    end

    self.update status: :TransactionCommitted
    self.commitNextTask
    MyLogger.info "TaskModel: Task #{self.id}, committed successfully"
    return true
  end

  def commitNextTask
    tx = Transaction.new
    tx.participate self.next.url
    tx.commit
  end

   def rollback
    MyLogger.info "TaskModel: Task #{self.id}, trying to rollback all subtasks"
    self.update status: :TransactionRolledBack
    return true
   end
end

