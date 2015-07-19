module Config
  TS_MANAGER_ADDR = 'narayana.bihe.docker'
  TS_MANAGER_PORT = 8080
  TS_MANAGER_URL = "http://#{Config::TS_MANAGER_ADDR}:#{Config::TS_MANAGER_PORT}/rest-at-coordinator/tx/transaction-manager"
  APP_HOST = "#{ENV['DNSDOCK_NAME']}.#{ENV['DNSDOCK_IMAGE']}.docker"
  APP_PORT = 4567
end

DataMapper.setup(:default, 'postgres://postgres:postgres@postgres.bihe.docker/postgres')
DataMapper.finalize
Task.auto_migrate!
Call.auto_migrate!

# Use this function for logging
def p(params)
  MyLogger.info params
end
