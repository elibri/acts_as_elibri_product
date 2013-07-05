# -*- encoding : utf-8 -*-
class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :record_reference, :null => false
      t.string :isbn
      t.string :title
      t.string :full_title
      t.string :trade_title
      t.string :original_title
      t.integer :publication_year
      t.integer :publication_month
      t.integer :publication_day
      t.integer :number_of_pages
      t.integer :duration
      t.integer :width
      t.integer :height
      t.string :cover_type
      t.string :edition_statement
      t.integer :audience_age_from
      t.integer :audience_age_to
      t.string :price_amount
      t.integer :vat
      t.string :pkwiu
      t.string :current_state
      t.string :product_form
      t.boolean :preview_exists, :default => false
      t.boolean :no_contributor, :default => false
      t.boolean :unnamed_persons, :default => false
      t.timestamps
    end
  end
end
