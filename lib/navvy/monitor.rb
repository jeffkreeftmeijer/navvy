require 'rubygems'
require 'sinatra'
require 'haml'

module Navvy
  class Monitor < Sinatra::Base
    set :views,   File.expand_path(File.dirname(__FILE__) + '/monitor/views')
    set :public,  File.expand_path(File.dirname(__FILE__) + '/monitor/public')
    set :static,  true
    
    get '/' do
      @pending_count =    Job.count(:failed_at => nil, :completed_at => nil)
      @completed_count =  Job.count(:completed_at => {'$ne' => nil})
      @failed_count =     Job.count(:failed_at => {'$ne' => nil})
      @jobs =             Job.all(:order => 'priority desc, created_at asc', :parent_id => nil, :limit => 100)
      haml :index, :layout => true
    end
  end
end
