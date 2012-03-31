class AddOldXmlToProductModel < ActiveRecord::Migration
  def up
    add_column :products, :old_xml, :text
  end

  def down
    remove_column :products, :old_xml
  end
end