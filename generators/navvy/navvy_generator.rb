class NavvyGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      options = {
        :migration_file_name => 'create_jobs'
      }
      m.migration_template 'migration.rb', 'db/migrate', options
      m.file 'script', 'script/navvy', :chmod => 0755
    end
  end

  def banner
    "Usage: #{$0} #{spec.name}"
  end
end
