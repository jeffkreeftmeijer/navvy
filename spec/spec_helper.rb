$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'navvy'
require 'rspec'
require 'timecop'

def job_count
  if defined? Navvy::Job.count
    Navvy::Job.count
  else
    Navvy::Job.all.length
  end
end

def first_job
  Navvy::Job.first
end

class Cow
  def self.speak
    'moo'
  end

  def self.broken
    raise 'this method is broken'
  end

  def self.broken_no_retry
    raise Navvy::Job::NoRetryException.new("this method is broken with no retry")
  end
end

module Animals
  class Cow
    def self.speak
      'moo'
    end

    def self.broken
      raise 'this method is broken'
    end
  end
end
