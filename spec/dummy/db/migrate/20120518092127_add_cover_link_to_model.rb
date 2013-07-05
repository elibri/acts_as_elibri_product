# -*- encoding : utf-8 -*-
class AddCoverLinkToModel < ActiveRecord::Migration
  def up
    add_column :products, :cover_link, :string
  end

  def down
    remove_column :products, :cover_link
  end
end
