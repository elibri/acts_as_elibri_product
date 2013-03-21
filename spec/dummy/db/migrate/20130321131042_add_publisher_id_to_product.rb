class AddPublisherIdToProduct < ActiveRecord::Migration
  def change
    add_column :products, :publisher_id, :integer
  end
end
