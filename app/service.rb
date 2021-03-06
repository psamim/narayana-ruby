require 'link_header'

class Service < Sinatra::Base
  enable :logging

  before '/task/:id*' do
    @task = Task.getWithType params[:id]
    # if the actor is unable to recover on the same URI then requests to the original endpoints
    # should return an HTTP status code of 301 (Moved Permanently)
    halt 301 if @task == nil
  end

  head '/task/:id' do
    links = LinkHeader.new([["#{@task.url}/terminator",    [["rel", "terminator"]]]]).to_s
    status 200
    headers "Link" => links
  end

  get '/task/:id' do
    headers(
      "Content-Length" => "--",
      "Content-Type" => "application/txstatus"
    )
    body "txstatus=#{@task.status}"
  end

  put '/task/:id/terminator' do
    body = request.body.read
    p "TX Manager PUT #{body} for Task #{@task.id}"
    newStatus = body[9, body.length].to_sym

    # If the participant is not in the correct state for the requested operation,
    # e.g., TransactionPrepared when it has already been prepared, then the service writer will return 412.
    halt 412 if @task.status == newStatus

    # After a request to change the resource state using TransactionRolledBack ,
    # TransactionCommitted or TransactionCommittedOnePhase, any subsequent PUT request will return a 409 or 410 code.
    halt 410 if [:TransactionCommitted, :TransactionCommittedOnePhase, :TransactionRolledBack].include? @task.status

    # If PUT fails, e.g., the participant cannot be prepared, then the service writer must return 409.
    if ! @task.txStatus newStatus
      p "Service: Task ID: #{@task.id}, Status: #{@task.status}, cannot set status"
      halt 409
    end

    if !@task.save
      p "Task ID: #{@task.id}, Status: #{@task.status}, cannot save task"
      halt 409
    end

    # If PUT is successful then the implementation returns 200.
    status 200
  end

  delete '/task/:id/terminator' do
    # Performing a DELETE on the participant-resource URI will cause the participant
    # to forget any heuristic decision it made on behalf of the transaction.
    # If the operation succeeds then 200 will be returned and the implementation will delete the resource;
  end

  after do
    p "HTTP RESPONSE, Task ID: #{@task.id}, Response: #{response.status}" unless @task == nil
  end

  get '/' do
    'Hello!'
  end
end
