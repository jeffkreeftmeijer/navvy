require 'rubygems'
require 'rake'

require 'spec/rake/spectask'

task :spec do
  ['spec:active_record', 'spec:mongo_mapper', 'spec:sequel', 'spec:data_mapper'].each do |spec|
    Rake::Task[spec].invoke
  end
end

namespace :spec do
  Spec::Rake::SpecTask.new(:active_record) do |spec|
    spec.spec_files = FileList['spec/setup/active_record.rb', 'spec/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:mongo_mapper) do |spec|
    spec.spec_files = FileList['spec/setup/mongo_mapper.rb', 'spec/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:sequel) do |spec|
    spec.spec_files = FileList['spec/setup/sequel.rb', 'spec/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:data_mapper) do |spec|
    spec.spec_files = FileList['spec/setup/data_mapper.rb', 'spec/*_spec.rb']
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
