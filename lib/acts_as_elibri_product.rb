module ActsAsElibriProduct
  extend ActiveSupport::Concern
  
  included do
  end

  module ClassMethods
    def acts_as_elibri_product(traverse_vector = {})
      @@traverse_vector = traverse_vector
    end
  end
  
  def update_product_from_elibri(new_xml)
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(read_attribute :old_xml).products.first
    product_updated = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(new_xml).products.first
    elibri_xml_versions = Elibri::XmlVersions.new(product, product_updated)
    details = elibri_xml_versions.diff
    details[:changes].each do |change|
      if change.is_a? Symbol && @@traverse_vector[change]
        write_attribute(@@traverse_vector[change], product_updated.send(change))
      elsif change.is_a? Hash && traverse_vector[change] && @@traverse_vector[change.keys.first]
        read_attribute(@@traverse_vector[change.keys.first]).send("#{@@traverse_vector[change[keys.first]]}=", product_updated.send(change.keys.first).send(change[keys.first]))
      elsif false #TODO: obsluga arrayow
        
      end
      
    end
    write_attribute(self.old_xml, new_xml)
  end
  
  def self.create_from_elibri(xml_string)
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml_string).products.first
    db_product = self.new
    @@traverse_vector.each_pair do |k, v|
      db_product.send(k) = product.send(v)
      db_product.old_xml = xml_string
      db_product.save
    end
  end
  
  def self.create_or_update_from_elibri(xml_string)
    recreated_product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml_string).products.first
    if Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference})
    #update
      Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference}).update_product_from_elibri(xml_string)
    else
      Product.create_from_elibri(xml_string)
    end
  end
      
end


ActiveRecord::Base.send :include, ActsAsElibriProduct