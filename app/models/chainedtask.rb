require 'narayana/transaction'
require 'models/task'

class ChainedTask < Task
  def type
    :Chained
  end

  def commit
    if self.fails
      w "TaskModel: Task #{self.id}, Task failed."
      self.rollback
      return false
    end

    self.update status: :TransactionCommitted
    self.commitNextTask
    p "TaskModel: Task #{self.id}, committed successfully"
    return true
  end

  def rollback
    p "TaskModel: Task #{self.id}, rolled back"
    self.update status: :TransactionRolledBack
    p "TaskModel: Task #{self.id}, trying to rollback prev. task"
    self.prev.rollback if self.prev
    return true
  end

  def commitNextTask
    tx = Transaction.new
    tx.participate self.next.url
    tx.commit
  end
end

