class Task
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :status,
           Enum[ :TransactionActive,
                 :TransactionPrepared,
                 :TransactionCommited,
                 :TransactionCommitedOnePhase,
                 :TransactionRolledBack
               ],
           :default => :TransactionActive

  def url
    "http://#{Config::APP_HOST}:#{Config::APP_PORT}/task/#{self.id}"
  end
end
