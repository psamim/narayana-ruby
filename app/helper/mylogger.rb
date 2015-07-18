require 'logger'

class MyLogger
  def self.logger
    if @_logger.nil?
      @_logger = Logger.new STDOUT
      @_logger.level = Logger::INFO
    end
    @_logger
  end

  def self.info(params)
    self.logger.info(params)
  end

  def self.warn(params)
    self.logger.warn(params)
  end
end
