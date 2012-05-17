class CreateRelatedProducts < ActiveRecord::Migration
  def change
    create_table :related_products do |t|
      t.integer :product_id
      t.string :related_record_reference
      t.string :onix_code

      t.timestamps
    end
  end
end
