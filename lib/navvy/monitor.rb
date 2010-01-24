require 'rubygems'
require 'sinatra'
require 'haml'

module Navvy
  class Monitor < Sinatra::Base
    set :views,   File.expand_path(File.dirname(__FILE__) + '/monitor/views')
    set :public,  File.expand_path(File.dirname(__FILE__) + '/monitor/public')
    set :static,  true
    
    get '/' do
      @jobs = Job.all(:order => 'priority desc, created_at asc')
      haml :index, :layout => true
    end
  end
end
