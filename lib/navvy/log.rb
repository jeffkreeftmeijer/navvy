module Navvy
  class Log

    ##
    # Pass a log to the logger.
    #
    # @param [String] message the message you want to log

    def self.info(message)
      puts message
      RAILS_DEFAULT_LOGGER.info(message)
    end
  end
end
