# -*- encoding : utf-8 -*-
class CreateImprints < ActiveRecord::Migration
  def change
    create_table :imprints do |t|
      t.integer :product_id
      t.string :name

      t.timestamps
    end
  end
end
