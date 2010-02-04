module Navvy
  class Log  
    class << self
      attr_writer :logger
      attr_accessor :quiet
    end
    
    class LoggerNotFound < StandardError; end

    ##
    # Default logger
    #
    # @return [Symbol, nil] logger

    def self.logger
      @logger || Navvy.configuration.logger
    end

    ##
    # Be quiet?
    #
    # @return [true, false] quiet

    def self.quiet
      @quiet || Navvy.configuration.quiet
    end

    ##
    # Pass a log to the logger. It will check if self.logger is an array. If it
    # is, it'll loop through it and log to every logger. If it's not, it'll
    # just log once.
    #
    # @param [String] message the message you want to log
    # @param [Integer] color an optional color code to use in the terminal
    # output

    def self.info(message, color = nil)
      if logger.is_a? Array
        logger.each do |logger|
          write(logger, message, color)
        end
      else
        write(logger, message, color)
      end
    end
    
    ##
    # Actually write the log to the logger. It'll check self.logger and use
    # that to define a logger
    #
    # @param [Symbol] logger the logger you want to use
    # @param [String] message the message you want to log
    # @param [Integer] color an optional color code to use in the terminal
    # output
    
    def self.write(logger, message, color = nil)
      puts "\e[#{color}m#{message}\e[0m" unless quiet
      case logger
      when :justlogging
        raise(
          LoggerNotFound,
          'JustLogging could not be found. No logs were created.'
        ) unless defined? Justlogging.log
        Justlogging.log(message)  
      when :rails
        raise(
          LoggerNotFound,
          'Rails.logger could not be found. No logs were created.'
        ) unless defined? Rails.logger.info
        Rails.logger.info(message)
      end
    end
  end
end
