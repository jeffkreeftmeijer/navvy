module Navvy
  class Job
    class << self
      attr_writer :limit, :keep, :max_attempts
    end

    ##
    # Default limit of jobs to be fetched.
    #
    # @return [Integer] limit

    def self.limit
      @limit || Navvy.configuration.job_limit
    end

    ##
    # If and how long the jobs should be kept.
    #
    # @return [Fixnum, true, false] keep

    def self.keep
      @keep || Navvy.configuration.keep_jobs
    end

    ##
    # How often should a job be retried?
    #
    # @return [Fixnum] max_attempts

    def self.max_attempts
      @max_attempts || Navvy.configuration.max_attempts
    end

    ##
    # Should the job be kept?
    #
    # @return [true, false] keep

    def self.keep?
      keep = (@keep || false)
      return (Time.now + keep) >= Time.now if keep.is_a? Fixnum
      keep
    end

    ##
    # Retry the current job. Will add self to the queue again, giving the clone
    # a parend_id equal to self.id.
    #
    # @return [true, false]

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
    # Check how long it took for a job to complete or fail
    #
    # @return [Time, Integer] time the time it took

    def duration
      ran? ? (completed_at || failed_at) - started_at : 0
    end

    ##
    # Check if completed_at is set
    #
    # @return [true, false] set?

    def completed_at?
      !completed_at.nil?
    end

    ##
    # Check if failed_at is set
    #
    # @return [true, false] set?

    def failed_at?
      !failed_at.nil?
    end

    ##
    # Get the job arguments as an array
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
  end
end