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

    ##
    # Daemonize the worker

    def self.daemonize(*args)
      if defined?(ActiveRecord)
        # Sets ActiveRecord's logger to Navvy a new Logger instance
        ActiveRecord::Base.logger = Logger.new(STDOUT)
      end
      
      # If #daemonize does not receive any arguments, the options variable will
      # contain an empty hash, and the ARGV of the environment will be used instead
      # of the :ARGV options from Daemons#run_proc. However, if the *args param has been set
      # this will be used instead of the environment's ARGV for the Daemons.
      options = args.empty? ? {} : {:ARGV => args}
      
      # Finally, the directory store mode will be set to normal and the Daemons PID file
      # will be stored inside tmp/pids of the application.
      options.merge!({:dir_mode => :normal, :dir => 'tmp/pids'})
      
      # Ensures that the tmp/pids folder exists so that the process id file can properly be stored
      %x(mkdir -p tmp/pids)
      
      # Runs the Navvy Worker inside a Daemon
      Daemons.run_proc('navvy', options) do
        Navvy::Worker.start
      end
    end
      
  end
end
