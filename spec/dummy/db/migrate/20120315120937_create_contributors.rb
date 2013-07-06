# -*- encoding : utf-8 -*-
class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.integer :import_id
      t.integer :product_id
      t.string :role_name
      t.string :role
      t.string :from_language
      t.string :full_name
      t.string :title
      t.string :first_name
      t.string :last_name_prefix
      t.string :last_name
      t.string :last_name_postfix
      t.text :biography

      t.timestamps
    end
  end
end
