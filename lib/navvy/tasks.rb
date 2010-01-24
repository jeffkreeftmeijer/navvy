task :environment

namespace :navvy do
  desc "Clear the Navvy queue."
  task :clear => :environment do
    Navvy::Job.delete_all
  end

  desc "Start a Navvy worker."
  task :work => :environment do
    Navvy::Worker.start
  end

  desc "Start the Navvy monitor"
  task :monitor => :environment do
    Navvy::Monitor.run!
  end
end