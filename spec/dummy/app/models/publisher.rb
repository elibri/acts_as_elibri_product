# -*- encoding : utf-8 -*-
class Publisher < ActiveRecord::Base
  has_many :products
  
  attr_accessible :name
end
