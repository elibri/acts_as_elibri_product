class ProductText < ActiveRecord::Base

  belongs_to :product, :touch => true
  
  attr_accessible :import_id, :text, :text_type, :text_author, :source_title, :resource_link
end