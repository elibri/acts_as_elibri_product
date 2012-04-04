class Imprint < ActiveRecord::Base
  attr_accessible :name, :product_id
  
  belongs_to :product
  
end
