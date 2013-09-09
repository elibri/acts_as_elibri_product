# -*- encoding : utf-8 -*-
class Contributor < ActiveRecord::Base

  belongs_to :product, :touch => true
  
#  attr_accessible :import_id, :role_name, :role, :from_language, :full_name, :title, :first_name, 
#                  :last_name_prefix, :last_name, :last_name_postfix, :biography
end
