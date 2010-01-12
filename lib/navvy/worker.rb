module Navvy
  class Worker
    
    ##
    # Start the worker.
    
    def self.start
      puts '*** Starting ***'
      trap('TERM') { puts '*** Exiting ***'; $exit = true }
      trap('INT')  { puts '*** Exiting ***'; $exit = true }
           
      loop do
        fetch_and_run_jobs
        
        if $exit
          puts '*** Cleaning up ***'
          Navvy::Job.cleanup
          break
        end
        sleep 5
      end
    end
    
    ##
    # Fetch jobs and run them.
    
    def self.fetch_and_run_jobs
      Job.next.each do |job|
        puts '*'
        job.run
      end
    end
  end
end
