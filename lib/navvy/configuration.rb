module Navvy
  class Configuration
    attr_accessor :job_limit, :keep_jobs, :logger, :quiet, :sleep_time
    
    def initialize
      @job_limit =  100
      @keep_jobs =  false
      @logger =     nil
      @quiet =      false
      @sleep_time = 5
    end
  end
end