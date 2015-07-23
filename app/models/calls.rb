class Call
  include DataMapper::Resource

  belongs_to :parent, 'Task', :key => true
  belongs_to :child, 'Task', :key => true
end

class Task
  has n, :links_to_childs, 'Task::Call', :child_key => [ :parent_id ]
  has n, :links_to_parents, 'Task::Call', :child_key => [ :child_id ]
end

class ChainedTask
  has 1, :next, self, :through => :links_to_childs, :via => :child
  has 1, :prev, self, :through => :links_to_parents, :via => :parent
end

class NestedTask
  has n, :subtasks, self, :through => :links_to_childs, :via => :child
  has 1, :parent, self, :through => :links_to_parents, :via => :parent
end
