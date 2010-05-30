module Navvy
  class Configuration
    attr_accessor :job_limit, :keep_jobs, :logger, :sleep_time, :max_attempts

    def initialize
      @job_limit =    100
      @keep_jobs =    false
      @logger =       Navvy::Logger.new
      @sleep_time =   5
      @max_attempts = 25
    end
  end
end
