class Call
  include DataMapper::Resource

  belongs_to :parent, 'Task', :key => true
  belongs_to :child, 'Task', :key => true
end

class Task
  has n, :links_to_childs, 'Task::Call', :child_key => [ :parent_id ]
  has n, :tasks, self, :through => :links_to_childs, :via => :child

  has n, :links_to_parents, 'Task::Call', :child_key => [:child_id]
  has n, :parents, self, :through => :links_to_parents, :via => :parent
end
