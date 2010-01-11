module Navvy
  class Worker
    
    ##
    # Start the worker.
    
    def self.start
      loop do
        fetch_and_run_jobs
        sleep 5
      end
    end
    
    ##
    # Fetch jobs an run them.
    
    def self.fetch_and_run_jobs
      Job.next.each do |job|
        job.run
      end
    end
  end
end
