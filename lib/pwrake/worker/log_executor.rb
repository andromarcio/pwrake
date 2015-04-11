module Pwrake

  class LogExecutor
    include Singleton
    extend Forwardable

    def_delegators :@logger, :debug, :info, :error, :fatal, :warn, :unknown
    def_delegators :@logger, :debug?, :info?, :error?, :fatal?, :warn?, :unknown?
    def_delegators :@logger, :level, :level=
    def_delegators :@logger, :formatter, :formatter=
    def_delegators :@logger, :datetime_format, :datetime_format=

    def initialize
      @level = ::Logger::DEBUG
      @logger = @logger_stderr = ::Logger.new($stderr)
      @logger.level = @level
    end

    def open(dir_class)
      @dir = dir_class.new
      @dir.open
      fn = "worker-#{`hostname`.chomp}-#{Process.pid}.log"
      @logfile = (@dir.log_path + fn).to_s
      @logger = @logger_file = ::Logger.new(@logfile)
      @logger_opened = true
      @logger.level = @level
      @dir.open_messages.each{|m| @logger.info(m)}
    end

    def close
      @dir.close_messages.each{|m| @logger.info(m)}
      @logger = @logger_stderr
      @logger_file.close
      @logger_file = nil
      @dir.close
    end

    def join
    end

    def kill(sig)
    end

  end
end