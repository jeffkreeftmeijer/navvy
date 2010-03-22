$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'navvy'
require 'spec'
require 'spec/autorun'

Navvy.configure do |config|
  config.quiet = true
end

module Navvy
  class Job
    class << self
      attr_writer :limit
    end

    attr_accessor :object, :method_name, :exception

    def self.limit
      Navvy.configuration.job_limit
    end

    def self.keep
      Navvy.configuration.keep_jobs
    end

    def self.max_attempts
      Navvy.configuration.max_attempts
    end

    def run
    end

    def failed?
      false
    end

    def args
      [1,2,3]
    end
  end
end
