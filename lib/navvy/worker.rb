module Navvy
  class Worker
    class << self
      attr_writer :sleep_time
    end

    ##
    # Sleep time of the worker.
    #
    # @return [Integer] sleep

    def self.sleep_time
      @sleep_time || Navvy.configuration.sleep_time
    end

    ##
    # Start the worker.

    def self.start
      Navvy.logger.info '*** Starting ***'
      trap('TERM') { Navvy.logger.info '*** Exiting ***'; $exit = true }
      trap('INT')  { Navvy.logger.info '*** Exiting ***'; $exit = true }

      loop do
        fetch_and_run_jobs

        if $exit
          Navvy.logger.info '*** Cleaning up ***'
          Navvy::Job.cleanup
          break
        end
        sleep sleep_time
      end
    end

    ##
    # Fetch jobs and run them.

    def self.fetch_and_run_jobs
      Job.next.each do |job|
        result = job.run
        Navvy.logger.colorized_info(
          "* #{job.object.to_s}.#{job.method_name}" <<
          "(#{job.args.join(', ')}) => #{(job.exception || result).to_s}",
          job.failed? ? 31 : 32
        )
      end
    end
  end
end
