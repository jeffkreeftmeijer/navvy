require 'mongo_mapper'

module Navvy
  class Job
    include MongoMapper::Document

    key :object,        String
    key :method_name,   Symbol
    key :arguments,     String
    key :priority,      Integer, :default => 0
    key :return,        String
    key :exception,     String
    key :backtrace,     String
    key :parent_id,     ObjectId
    key :created_at,    Time
    key :run_at,        Time
    key :started_at,    Time
    key :completed_at,  Time
    key :failed_at,     Time

    ##
    # Add a job to the job queue.
    #
    # @param [Object] object the object you want to run a method from
    # @param [Symbol, String] method_name the name of the method you want to
    # run
    # @param [*] arguments optional arguments you want to pass to the method
    #
    # @return [Job, false] created Job or false if failed

    def self.enqueue(object, method_name, *args)
      options = {}
      if args.last.is_a?(Hash)
        options = args.last.delete(:job_options) || {}
        args.pop if args.last.empty?
      end

      create(
        :object =>      object.to_s,
        :method_name => method_name.to_sym,
        :arguments =>   args.to_yaml,
        :priority =>    options[:priority] || 0,
        :parent_id =>   options[:parent_id],
        :run_at =>      options[:run_at] || Time.now,
        :created_at =>  Time.now
      )
    end

    ##
    # Find the next available jobs in the queue. This will not include failed
    # jobs (where :failed_at is not nil) and jobs that should run in the future
    # (where :run_at is greater than the current time).
    #
    # @param [Integer] limit the limit of jobs to be fetched. Defaults to
    # Navvy::Job.limit (ignored if Navvy::Job.parallel is true)
    #
    # @return [array, nil] the next available jobs in an array or nil if no
    # jobs were found.

    def self.next(limit = self.limit)
      query = {
        :failed_at =>     nil,
        :completed_at =>  nil,
        :run_at =>        {'$lte' => Time.now}
      }

      if Navvy::Job.parallel
        begin
          started = Time.now

          result = Navvy::Job.collection.find_and_modify(
            :query => query.merge(:started_at => nil),
            :update => { :$set => {:started_at => started} },
            :sort => 'priority desc, created_at asc'
          )

          # we could return the actual object by setting :new => true
          # but we know exactly what we set so there's no point waiting
          # update the returned document so it's the same as in the db
          [Navvy::Job.load(result.merge(:started_at => started))]

        rescue Mongo::OperationFailure => e
          # raises Mongo::OperationFailure when nothing is found (IE no jobs left)
          []
        end
      else
        all(
          query.merge(
            :order => 'priority desc, created_at asc',
            :limit => limit
          )
        )
      end
    end

    ##
    # Clean up jobs that we don't need to keep anymore. If Navvy::Job.keep is
    # false it'll delete every completed job, if it's a timestamp it'll only
    # delete completed jobs that have passed their keeptime.
    #
    # @return [true, false] delete_all the result of the delete_all call

    def self.cleanup
      if keep.is_a? Fixnum
        delete_all(
          :completed_at => {'$lte' => keep.ago}
        )
      else
        delete_all(
          :completed_at => {'$ne' => nil}
        ) unless keep?
      end
    end

    ##
    # Mark the job as started. Will set started_at to the current time.
    #
    # If running jobs in parallel, it's already marked as started so this is a no-op
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def started
      return if Navvy::Job.parallel
      update_attributes({
        :started_at =>  Time.now
      })
    end

    ##
    # Mark the job as completed. Will set completed_at to the current time and
    # optionally add the return value if provided.
    #
    # @param [String] return_value the return value you want to store.
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def completed(return_value = nil)
      update_attributes({
        :completed_at =>  Time.now,
        :return =>        return_value
      })
    end

    ##
    # Mark the job as failed. Will set failed_at to the current time and
    # optionally add the exception message if provided. Also, it will retry
    # the job unless max_attempts has been reached or retryable is false.
    #
    # @param [String] exception the exception message you want to store.
    # @param [true, false] whether or not to attempt to retry the job
    #
    # @return [true, false] update_attributes the result of the
    # update_attributes call

    def failed(message = nil, backtrace = nil, retryable = true)
      self.retry unless !retryable || times_failed >= self.class.max_attempts
      update_attributes(
        :failed_at => Time.now,
        :exception => message,
        :backtrace => backtrace.try(:join, "\n")
      )
    end

    ##
    # Check how many times the job has failed. Will try to find jobs with a
    # parent_id that's the same as self.id and count them
    #
    # @return [Integer] count the amount of times the job has failed

    def times_failed
      i = parent_id || id
      self.class.count(
        :failed_at => {'$ne' => nil},
        '$where' => "this._id == '#{i}' || this.parent_id == '#{i}'"
      )
    end
  end
end

require 'navvy/job'
