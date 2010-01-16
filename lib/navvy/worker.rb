module Navvy
  class Worker

    ##
    # Start the worker.

    def self.start
      Navvy::Log.info '*** Starting ***'
      trap('TERM') { Navvy::Log.info '*** Exiting ***'; $exit = true }
      trap('INT')  { Navvy::Log.info '*** Exiting ***'; $exit = true }

      loop do
        fetch_and_run_jobs

        if $exit
          Navvy::Log.info '*** Cleaning up ***'
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
        job.run
        Navvy::Log.info(
          "* #{job.object}.#{job.method}" <<
          "(#{job.args.join(', ')}) => #{(job.return || job.exception).to_s}",
          job.failed? ? 31 : 32
        )
      end
    end
  end
end
