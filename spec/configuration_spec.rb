require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Navvy::Configuration do
  after do
    Navvy.configure do |config|
      config.job_limit =  100
      config.keep_jobs =  false
      config.logger =     nil
      config.quiet =      true
      config.sleep_time = 5
    end
  end
  
  it 'should have a job limit of 100 by default' do
    Navvy::Job.limit.should == 100
  end
  
  it 'should set the job limit' do
    Navvy.configure do |config|
      config.job_limit = 10
    end
    
    Navvy::Job.limit.should == 10
  end
  
  it 'should have keep_jobs off by default' do
    Navvy::Job.keep.should == false
  end
  
  it 'should set keep_jobs' do
    Navvy.configure do |config|
      config.keep_jobs = 10
    end
    
    Navvy::Job.keep.should == 10
  end
  
  it 'should not have a logger by default' do
    Navvy::Log.logger.should == nil
  end
  
  it 'should set the keep_jobs' do
    Navvy.configure do |config|
      config.logger = :rails
    end
    
    Navvy::Log.logger.should == :rails
  end
  
  it 'should be quiet in the specs' do
    Navvy::Log.quiet.should == true
  end
  
  it 'should turn quiet off' do
    Navvy.configure do |config|
      config.quiet = false
    end
    
    Navvy::Log.quiet.should == false
  end
  
  it 'should have a default sleep time of 5' do
    Navvy::Worker.sleep_time.should == 5
  end
  
  it 'should turn quiet off' do
    Navvy.configure do |config|
      config.sleep_time = 10
    end
    
    Navvy::Worker.sleep_time == 10
  end
end