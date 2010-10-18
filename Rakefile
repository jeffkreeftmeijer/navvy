require 'rubygems'
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rake'
require 'spec/rake/spectask'

adapters = Dir[File.dirname(__FILE__) + '/lib/navvy/job/*.rb'].map{|file| File.basename(file, '.rb') }

task :spec do
  adapters.map{|adapter| "spec:#{adapter}"}.each do |spec|
    Rake::Task[spec].invoke
  end
end

namespace :spec do
  adapters.each do |adapter|
    Spec::Rake::SpecTask.new(adapter) do |spec|
      spec.spec_files = FileList["spec/setup/#{adapter}.rb", 'spec/*_spec.rb']
    end
  end
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
