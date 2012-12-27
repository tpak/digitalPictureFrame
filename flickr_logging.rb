module Logging
  # This is the magical bit that gets mixed into your classes
  def log
    Logging.logger
  end

  def get_method
    caller[0][/`([^']*)'/, 1]
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @log ||= Logger.new(STDOUT)
  end
end