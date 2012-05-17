class RelatedProduct < ActiveRecord::Base
  attr_accessible :onix_code, :product_id, :related_record_reference
end
