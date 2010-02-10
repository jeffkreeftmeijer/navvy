require 'rubygems'
require 'daemons'

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
        sleep sleep_time
      end
    end

    ##
    # Fetch jobs and run them.

    def self.fetch_and_run_jobs
      Job.next.each do |job|
        result = job.run
        Navvy::Log.info(
          "* #{job.object.to_s}.#{job.method_name}" <<
          "(#{job.args.join(', ')}) => #{(job.exception || result).to_s}",
          job.failed? ? 31 : 32
        )
      end
    end

    ##
    # Daemonize the worker

    def self.daemonize(*args)
      options = args.empty? ? {} : {:ARGV => args}
      Daemons.run_proc('navvy', options) do
        Navvy::Worker.start
      end
    end
  end
end
