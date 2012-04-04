class AddOldXmlTo<%= model_name %>Model < ActiveRecord::Migration
  def up
    add_column :<%= table_name %>, :old_xml, :text
  end

  def down
    remove_column :<%= table_name %>, :old_xml
  end
end