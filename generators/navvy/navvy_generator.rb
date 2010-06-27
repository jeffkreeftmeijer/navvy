class NavvyGenerator < Rails::Generator::Base
  default_options :orm => 'active_record'

  def manifest
    record do |m|
      m.migration_template "#{options[:orm]}_migration.rb", 'db/migrate', {:migration_file_name => 'create_jobs'}
    end
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on('--active_record', 'Generate a migration file for ActiveRecord. (default)') { options[:orm] = 'active_record' }
    opt.on('--sequel', 'Generate a migration file for Sequel.') { options[:orm] = 'sequel' }
  end

  def banner
    "Usage: #{$0} #{spec.name}"
  end
end
