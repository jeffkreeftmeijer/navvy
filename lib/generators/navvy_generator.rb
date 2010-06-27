require 'rails/generators/migration'
class NavvyGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  class_option :active_record,
    :desc => 'Generate a migration file for ActiveRecord. (default)',
    :type => 'boolean'

  class_option :sequel,
    :desc => 'Generate a migration file for Sequel.',
    :type => 'boolean'

  def self.source_root
    File.join(File.dirname(__FILE__), '..', '..', 'generators', 'navvy', 'templates')
  end

  def install_navvy
    migration_template(
      "#{orm}_migration.rb",
      'db/migrate/create_jobs.rb'
    )
  end

  def orm
    options[:sequel] ? 'sequel' : 'active_record'
  end

  protected
    def self.next_migration_number(dirname) #:nodoc:
      "%.3d" % (current_migration_number(dirname) + 1)
    end
end
