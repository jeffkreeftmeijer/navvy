require 'rails/generators/migration'
class NavvyGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  class_option :orm,
    :desc => 'The ORM you\'re using in your application. ' <<
      'Navvy can generate migration files for ActiveRecord and Sequel.',
     :type => 'string'

  def self.source_root
    File.join(File.dirname(__FILE__), '..', '..', 'generators', 'navvy', 'templates')
  end

  def install_navvy
    if %w{active_record sequel}.include? orm
      migration_template(
        "#{orm}_migration.rb",
        'db/migrate/create_jobs.rb'
      )
    else
      puts 'Sorry, there are no generators for the \"#{orm}\" ORM. ' <<
        'The available generators are \"active_record\" and \"sequel\". ' <<
        'Please check your input, maybe you mistyped something. '
    end
  end

  def orm
    @orm ||= options[:orm].to_s.downcase
  end

  protected
    def self.next_migration_number(dirname) #:nodoc:
      "%.3d" % (current_migration_number(dirname) + 1)
    end
end
