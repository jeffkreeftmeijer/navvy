require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "navvy"
    gem.summary = %Q{Simple background job processor inspired by delayed_job, but aiming for database agnosticism.}
    gem.description = %Q{Simple background job processor inspired by delayed_job, but aiming for database agnosticism.}
    gem.email = "jeff@kreeftmeijer.nl"
    gem.homepage = "http://github.com/jeffkreeftmeijer/navvy"
    gem.authors = ["Jeff Kreeftmeijer"]
    gem.add_development_dependency "rspec",                 ">= 1.2.9"
    gem.add_development_dependency "yard",                  ">= 0.5.2"
    gem.add_development_dependency "metric_fu",             ">= 1.1.6"
    gem.add_development_dependency "machinist",             ">= 1.0.6"
    gem.add_development_dependency "mongo_mapper",          ">= 0.6.10"
    gem.add_development_dependency "machinist_mongomapper", ">= 0.9.7"
    gem.add_development_dependency "sequel",                ">= 3.8.0"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'

task :spec do
  ['spec:active_record', 'spec:mongo_mapper', 'spec:sequel'].each do |spec|
    Rake::Task[spec].invoke
  end
end

namespace :spec do
  Spec::Rake::SpecTask.new(:active_record) do |spec|
    spec.spec_files = FileList['spec/job/active_record_spec.rb', 'spec/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:mongo_mapper) do |spec|
    spec.spec_files = FileList['spec/job/mongo_mapper_spec.rb', 'spec/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:sequel) do |spec|
    spec.spec_files = FileList['spec/job/sequel_spec.rb', 'spec/*_spec.rb']
  end
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies
task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end

require 'metric_fu'
