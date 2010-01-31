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
  elsif defined? Navvy::Job.all.destroy
    Navvy::Job.all.destroy
  else
    Navvy::Job.delete
  end
end

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
end

Navvy.configure do |config|
  config.quiet = true
end
