require 'logger'

module Navvy
  class Logger < Logger
    def initialize(logdev = nil)
      super(logdev || STDOUT)
    end

    def colorized_info(message, color)
      unless @logdev.filename
        return info("\e[#{color}m#{message}\e[0m")
      end
      info(message)
    end
  end
end
