require 'rubygems'
require 'sinatra'

module Navvy
  class Monitor < Sinatra::Base
    get '/' do
      '<h1>Navvy Monitor</h1>'
    end
  end
end
