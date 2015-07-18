require 'httparty'
require 'link_header'

class Transaction
  attr_reader :url
  attr_reader :response

  def initialize
    MyLogger.info "Tx: Initializing a new transaction"

    response = HTTParty.post(
      Config::TS_MANAGER_URL,
      headers: {"mediaType" => "application/x-www-form-urlencoded"}
    )
    @url = response.headers['location']

    MyLogger.info "Tx: Transaction initialized #{@url}"
  end

  def status
    @response = HTTParty.get(
      @url,
      headers: {"Accept" => "application/txstatus"}
    )
    if @response.code != 404
      return @response.body
    end
  end

  def status=(newStatus)
    MyLogger.info "Tx: Putting #{newStatus} to transaction #{@url}"

    @response = HTTParty.put(
      "#{@url}/terminator",
      headers: {
        "Content-Type" => "application/txstatus",
        "Content-Length" => "--"
      },
      body: "txstatus=#{newStatus}"
    )
  end

  def commit
    self.status = :TransactionCommitted
  end

  def rollback
    self.status = :TransactionRolledBack
  end

  def all
    response = HTTParty.get(
      Config::TS_MANAGER_URL,
      headers: {
        "Accept" => "application/txlist"
      }
    )
    response.body
  end

  def participate(resource)
    MyLogger.info "Tx: participate #{resource} in #{@url}"

    links = LinkHeader.new(
      [["#{resource}", [["rel", "participant"]]],
       ["#{resource}/terminator",    [["rel", "terminator"]]]]
    ).to_s
    response = HTTParty.post(
      @url,
      headers: {
        "Link" => links
      }
    )

    MyLogger.info "Tx: status #{response.code}, participate #{resource} in #{@url}"
    puts response
    response
  end
end
