class CreatePublisherTable < ActiveRecord::Migration
  def change
    create_table :publishers do |t|
      t.string :name
    end
  end
end
