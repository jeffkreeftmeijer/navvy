require 'rubygems'
require 'sinatra'
require 'haml'

module Navvy
  class Monitor < Sinatra::Base
    set :views,   File.expand_path(File.dirname(__FILE__) + '/monitor/views')
    set :public,  File.expand_path(File.dirname(__FILE__) + '/monitor/public')
    set :static,  true

    get '/' do
      redirect '/pending'
    end

    get '/pending' do
      @jobs = Job.pending
      haml :index, :layout => true
    end

    get '/completed' do
      @jobs = Job.completed
      haml :index, :layout => true
    end

    get '/failed' do
      @jobs = Job.failed
      haml :index, :layout => true
    end

    get '/:id' do
      @jobs = Job.family(params[:id])
      haml :show
    end
  end
end
