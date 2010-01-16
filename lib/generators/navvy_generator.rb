require 'rails/generators'
class NavvyGenerator < Rails::Generators::Base
  
  def self.source_root
    File.join(File.dirname(__FILE__), '..', '..', 'generators', 'navvy', 'templates')
  end
  
  def install_navvy
    copy_file(
      'migration.rb',
      'db/migrate/create_navvy_table.rb'
    )
  end
end
