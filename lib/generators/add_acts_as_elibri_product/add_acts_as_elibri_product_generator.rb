require 'rails/generators'
require 'rails/generators/migration'

class AddActsAsElibriProductGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  source_root File.expand_path('../templates', __FILE__)
  argument :model_name, :type => :string
  
  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end
  
  def migration 
    migration_template "add_old_xml_to_model.rb", "db/migrate/add_old_xml_to_#{model_name.underscore}_model.rb"
  end
  
  private
  
  def table_name
    model_name.pluralize.underscore
  end
  
end
