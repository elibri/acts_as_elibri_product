# -*- encoding : utf-8 -*-
class RelatedProduct < ActiveRecord::Base
#  attr_accessible :onix_code, :product_id, :related_record_reference
  
  belongs_to :product
  
  def object
    Product.where(:record_reference => related_record_reference).first
  end
  
  def self.objects
    joins(:product).first.product.related_products.map { |x| Product.where(:record_reference => x.related_record_reference).first }.compact
  end
  
end
