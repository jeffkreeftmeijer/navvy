$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'navvy'
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
end

def delete_all_jobs
  if defined? Navvy::Job.delete_all
    Navvy::Job.delete_all
  else
    Navvy::Job.delete
  end
end

def job_count
  Navvy::Job.count
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
end

Navvy::Log.quiet = true
