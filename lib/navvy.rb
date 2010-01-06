module Navvy
  class Worker
    def self.start
      puts '*** Started ***'
      loop do
        if job = Job.next
          result = job.run
          if job.failed_at?
            puts "* #{Time.now} - Job failed - '#{job.exception}'"
          else
            puts "* #{Time.now} - Job complete - '#{result}'"
          end
        end
        sleep 1
      end
    end
  end
end
