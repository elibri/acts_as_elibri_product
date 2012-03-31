class CreateProductTexts < ActiveRecord::Migration
  def change
    create_table :product_texts do |t|
      t.integer :import_id
      t.integer :product_id
      t.text :text
      t.string :type
      t.string :text_author
      t.string :source_title
      t.string :resource_link

      t.timestamps
    end
  end
end
