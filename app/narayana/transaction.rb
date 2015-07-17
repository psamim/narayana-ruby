require 'httparty'
require 'link_header'

class Transaction
  attr_reader :url
  attr_reader :response

  def initialize
    response = HTTParty.post(
      Config::TS_MANAGER_URL,
      headers: {"mediaType" => "application/x-www-form-urlencoded"}
    )
    @url = response.headers['location']
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
    self.status = "TransactionCommitted"
  end

  def rollback
    self.status = "TransactionRolledBack"
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
    links = LinkHeader.new(
      [["#{resource}", [["rel", "participant"]]],
       ["#{resource}/terminator",    [["rel", "terminator"]]]]
    ).to_s
    puts links
    response = HTTParty.post(
      @url,
      headers: {
        "Link" => links
      }
    )
    response
  end
end
