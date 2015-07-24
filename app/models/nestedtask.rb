
require 'models/task'

class NestedTask < Task
  def type
    :Nested
  end

  def commit
    if self.fails
      w "TaskModel: Task #{self.id}, Task failed."
      return false
    elsif (self.parent and self.parent.status == :TransactionCommitted) or !self.parent
      self.update status: :TransactionCommitted
      self.commitChilds
      p "TaskModel: Task #{self.id}, committed successfully."
      p "TaskModel: Task #{self.id}, trying to commit childs."
      return true
    else
      p "TaskModel: Task #{self.id}, commit failed."
      self.rollback
      return false
    end
  end

  def rollback
    p "TaskModel: Task #{self.id}, trying to rollback"
    self.update status: :TransactionRolledBack
    return true
  end

  def prepare
    self.commit
  end

  def commitChilds
    if self.childs.empty?
      p "TaskModel: Task #{self.id}, has no childs."
      return true
    end

    # Commit all childs in a transaction
    tx = Transaction.new
    self.childs.each do |t|
      tx.participate t.url
    end
    tx.commit
  end
end
