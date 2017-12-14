require 'stringio'
require 'logger'

module LoggerCapture
  def self.included(src)
    src.before do
      Oriented.logger = logger
    end
    src.after do
      puts log_dev.string if example.exception
    end
  end

  def log_dev
    @log_dev ||= StringIO.new
  end

  def logger
    @logger ||= Logger.new(log_dev)
  end
end
