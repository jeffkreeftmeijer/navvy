require 'rake'
require 'rspec/core/rake_task'

adapters = Dir[File.dirname(__FILE__) + '/lib/navvy/job/*.rb'].map{|file| File.basename(file, '.rb') }

task :rspec do
  adapters.map{|adapter| "rspec:#{adapter}"}.each do |spec|
    Rake::Task[spec].invoke
  end
end

namespace :rspec do
  adapters.each do |adapter|
    RSpec::Core::RakeTask.new(adapter) do |spec|
      if adapter=="sequelhooks"
        spec.pattern = "spec/zhooks.rb", "spec/setup/#{adapter}.rb", "spec/*_spec.rb" 
      else
        spec.pattern = "spec/setup/#{adapter}.rb", 'spec/*_spec.rb'
      end
    end
  end
end

task :default => :rspec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
