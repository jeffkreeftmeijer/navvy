module Navvy
  class Job
    class << self
      attr_writer :limit, :keep, :max_attempts
    end

    ##
    # Limit of jobs to be fetched at once. Will use the value stored in
    # Navvy.configuration (defaults to 100), or -- for backwards compatibility
    # -- Navvy::Job.limit.
    #
    # @return [Integer] limit

    def self.limit
      @limit || Navvy.configuration.job_limit
    end

    ##
    # If and how long the jobs should be kept. Will use the value stored in
    # Navvy.configuration (defaults to false), or -- for backwards
    # compatibility -- Navvy::Job.keep.
    #
    # @return [Fixnum, true, false] keep

    def self.keep
      @keep || Navvy.configuration.keep_jobs
    end

    ##
    # How often should a job be retried? Will use the value stored in
    # Navvy.configuration (defaults to 24), or -- for backwards compatibility
    # -- Navvy::Job.max_attempts.
    #
    # @return [Fixnum] max_attempts

    def self.max_attempts
      @max_attempts || Navvy.configuration.max_attempts
    end

    ##
    # Should the job be kept? Will calculate if the keeptime has passed if
    # @keep is a Fixnum. Otherwise, it'll just return the @keep value since
    # it's probably a boolean.
    #
    # @return [true, false] keep

    def self.keep?
      return (Time.now + self.keep) >= Time.now if self.keep.is_a? Fixnum
      self.keep
    end

    ##
    # Run the job. Will delete the Navvy::Job record and return its return
    # value if it runs successfully unless Navvy::Job.keep is set. If a job
    # fails, it'll call Navvy::Job#failed and pass the exception message.
    # Failed jobs will _not_ get deleted.
    #
    # @example
    #   job = Navvy::Job.next # finds the next available job in the queue
    #   job.run               # runs the job and returns the job's return value
    #
    # @return [String] return value or exception message of the called method.

    def run
      begin
        started
        result = constantize(object).send(method_name, *args)
        Navvy::Job.keep? ? completed : destroy
        result
      rescue Exception => exception
        failed(exception.message)
      end
    end

    ##
    # Retry the current job. Will add self to the queue again, giving the clone
    # a parend_id equal to self.id. Also, the priority of the new job will be
    # the same as its parent's and it'll set the :run_at date to N ** 4, where
    # N is the times_failed count.
    #
    # @return [Navvy::Job] job the new job it created.

    def retry
      self.class.enqueue(
        object,
        method_name,
        *(args << {
          :job_options => {
            :parent_id => parent_id || id,
            :run_at => Time.now + times_failed ** 4,
            :priority => priority
          }
        })
      )
    end

    ##
    # Check if the job has been run.
    #
    # @return [true, false] ran

    def ran?
      completed? || failed?
    end

    ##
    # Check how long it took for a job to complete or fail.
    #
    # @return [Time, Integer] time the time it took.

    def duration
      ran? ? (completed_at || failed_at) - started_at : 0
    end

    ##
    # Check if completed_at is set.
    #
    # @return [true, false] set?

    def completed_at?
      !completed_at.nil?
    end

    ##
    # Check if failed_at is set.
    #
    # @return [true, false] set?

    def failed_at?
      !failed_at.nil?
    end

    ##
    # Get the job arguments as an array.
    #
    # @return [array] arguments

    def args
      arguments.is_a?(Array) ? arguments : YAML.load(arguments)
    end

    ##
    # Get the job status
    #
    # @return [:pending, :completed, :failed] status

    def status
      return :completed if completed?
      return :failed if failed?
      :pending
    end

    alias_method :completed?, :completed_at?
    alias_method :failed?,    :failed_at?
	
	private
		
		##
		# Turn a constant with potential namespacing into an object
		#
		# @return [Class] class
		
		def constantize(str)
			names = str.split('::')
			names.shift if names.empty? || names.first.empty?
			constant = Object
			names.each do |name|
				constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
			end
			constant
		end
  end
end