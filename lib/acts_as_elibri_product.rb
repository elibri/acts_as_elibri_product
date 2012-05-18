require 'elibri_xml_versions'
require 'ostruct'

module ActsAsElibriProduct
  extend ActiveSupport::Concern
  
  included do
  end

  module ClassMethods
    
    def self.traverse_vector
      @@traverse_vector
    end
    
    @@traverse_vector = {}
        
    def acts_as_elibri_product(traverse_vector = {})
      @@traverse_vector = traverse_vector
    end
    
    @@policy_chain = []
    
    def policy_chain
      @@policy_chain
      ### policy musi przyjmowac cztery argumenty -> nazwa obiektu (jesli main level to product po prostu), nazwa atrybutu, wartosc przed, wartosc po
    end
    
    def validate_policy_chain
      @@policy_chain.each do |policy|
        raise "Policy #{policy} don't respond to call method" unless policy.respond_to? :call
      end
      return true
    end
    
    def create_from_elibri(xml_string)
      product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml_string).products.first
      db_product = self.new
      @@traverse_vector.each_pair do |k, v|
        if v.is_a?(Symbol)
          db_product.send(:write_attribute, v, product.send(k))
        elsif v.is_a?(Hash)
          object = db_product.send(v.keys.first)
          ActsAsElibriProduct.set_objects_from_array(k, v.keys.first, v.values.first, product.send(k), db_product) if product.send(k)
        elsif v.is_a?(Array)
          if v[0].nil?
            v[1].call(db_product, product.send(k))
          else
            db_product.send(:write_attribute, v[0], v[1].call(db_product, product.send(k)))
          end
        end
      end
      db_product.old_xml = xml_string
      db_product.save
    end

    def create_or_update_from_elibri(xml_string)
      recreated_product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml_string).products.first
      if Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference})
      #update
        Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference}).update_product_from_elibri(xml_string)
      else
        Product.create_from_elibri(xml_string)
      end
    end
    
    def batch_create_or_update_from_elibri(xml_string)
      if xml_string.is_a?(Elibri::ONIX::Release_3_0::ONIXMessage)
        recreated_products = xml_string
      else
        recreated_products = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml_string)
      end
      recreated_products.products.each do |product|
        xml = product.to_xml.to_s
        dialect = product.elibri_dialect
        header = "<?xml version='1.0' encoding='UTF-8'?>
                  <ONIXMessage xmlns:elibri='http://elibri.com.pl/ns/extensions' xmlns='`http://www.editeur.org/onix/3.0/reference' release='3.0'>
                      <elibri:Dialect>#{dialect}</elibri:Dialect>"

        xml = header + xml + "</ONIXMessage>"
        create_or_update_from_elibri(xml)
      end
    end
    
  end
  
  def update_product_from_elibri(new_xml)
    if (read_attribute :old_xml).blank?
      raise "Empty old_xml column on product"
    end
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(read_attribute :old_xml).products.first
    product_updated = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(new_xml).products.first
    elibri_xml_versions = Elibri::XmlVersions.new(product, product_updated)
    details = elibri_xml_versions.diff
    details[:changes].each do |change|
      if change.is_a?(Symbol) && traverse_vector[change]
        if traverse_vector[change].is_a?(Array)
          next unless check_policy_chain(self, :product, traverse_vector[change], self.send(traverse_vector[change][0]), product_updated.send(change))
          if traverse_vector[change][0].nil?
            traverse_vector[change][1].call(self, product_updated.send(change))
          else
            write_attribute(traverse_vector[change][0], traverse_vector[change][1].call(self, product_updated.send(change)))
          end
        else
          next unless check_policy_chain(self, :product, traverse_vector[change], self.send(traverse_vector[change]), product_updated.send(change))
          write_attribute(traverse_vector[change], product_updated.send(change))
        end
      elsif change.is_a?(Hash) && traverse_vector[change.keys.first]        
        change.values.first.each do |elibri_attrib|
          if elibri_attrib.is_a? Hash
            elibri_attrib.each_pair do |k,v|
              db_attrib = traverse_vector[change.keys.first].values.first[v]
              if db_attrib #found in mapping
                object = self.send(traverse_vector[change.keys.first].keys.first).find { |x| x.import_id == k }
                elibri_object = product_updated.send(change.keys.first).find { |x| x.id == k }
                if v.is_a?(Array)
                  next unless check_policy_chain(self, traverse_vector[change.keys.first].keys.first, db_attrib, object.send(db_attrib), elibri_object.send(v[0]))
                  if v[0].nil?
                    v[1].call(self, elibri_object.send(v[0]))
                  else
                    object.send(:write_attribute, db_attrib, v[1].call(self, elibri_object.send(v[0])))
                  end
                else
                  next unless check_policy_chain(self, traverse_vector[change.keys.first].keys.first, db_attrib, object.send(db_attrib), elibri_object.send(v))
                  object.send(:write_attribute, db_attrib, elibri_object.send(v))
                end
              end
            end
          else
            if traverse_vector[change.keys.first].is_a?(Array)
              next unless check_policy_chain(self, change.keys.first, elibri_attrib, product.send(change.keys.first).send(elibri_attrib), product_updated.send(change.keys.first).send(elibri_attrib))
              if traverse_vector[change.keys.first][0].nil?
                traverse_vector[change.keys.first][1].call(self, product_updated.send(change.keys.first))
              else
                ### TO BE IMPLEMENTED - not quite sure if this situation may and should happen
              end
            else
              db_attrib = traverse_vector[change.keys.first].values.first[elibri_attrib]
              object = self.send(traverse_vector[change.keys.first].keys.first)
              elibri_object = product_updated.send(change.keys.first)
              next unless check_policy_chain(self, traverse_vector[change.keys.first].keys.first, db_attrib, object.send(db_attrib), elibri_object.send(elibri_attrib))            
              object.send(:write_attribute, db_attrib, elibri_object.send(elibri_attrib))
            end
          end
        end
    #    read_attribute(traverse_vector[change.keys.first]).send("#{traverse_vector[change[keys.first]]}=", product_updated.send(change.keys.first).send(change[keys.first]))
      else
        #nieistotne :)
      end
    details[:deleted].each do |deleted|
      if traverse_vector[deleted.keys.first] && traverse_vector[deleted.keys.first].keys.first       
        deleted.each_pair do |dele_key, dele|
          dele.each do |del|
            self.send(traverse_vector[dele_key].keys.first).each { |x| x if x.send(traverse_vector[dele_key].values.first[:id]) == del.id }.compact.each(&:delete)
          end
        end
      end
    end
    details[:added].each do |added|
      if traverse_vector[added.keys.first] && traverse_vector[added.keys.first].keys.first
        ActsAsElibriProduct.set_objects_from_array(traverse_vector[added.keys.first], traverse_vector[added.keys.first].keys.first, traverse_vector[added.keys.first].values.first, added.values.first, self)
 #       object = self.send(traverse_vector[added.keys.first].keys.first)
#        ActsAsElibriProduct.set_objects_from_array(traverse_vector[added.keys.first].keys.fir, v.keys.first, v.values.first, product.send(k), db_product)
      end
    end
    write_attribute(:old_xml, new_xml)
    self.save
  
  end
  
end
  
  def traverse_vector
    ActsAsElibriProduct::ClassMethods.traverse_vector
  end
  
  def check_policy_chain(product, object, attribute, pre, post)
    product.class.policy_chain.all? { |policy| policy.call(object, attribute, pre, post) }
  end
  
  def self.set_objects_from_array(elibri_object_name, db_object_name, object_traverse_vector, elibri_objects, db_product)
    if elibri_objects.is_a?(Array)
      elibri_objects.each do |elibri_object|
        db_product.send(db_object_name).build.tap do |inner_object|
      #    db_product.send
          object_traverse_vector.each_pair do |k, v|
            if v.is_a?(Hash)
              #TODO
             # set_objects_from_array(object.send(v.keys.first), v.values.first, product, k)
            else
              inner_object.send(:write_attribute, v, elibri_object.send(k))
            end
          end
        end
      end
    else
      db_product.send("build_#{db_object_name}").tap do |inner_object|
    #    db_product.send
        object_traverse_vector.each_pair do |k, v|
          if v.is_a?(Hash)
            #TODO
           # set_objects_from_array(object.send(v.keys.first), v.values.first, product, k)
          else
            inner_object.send(:write_attribute, v, elibri_objects.send(k))
          end
        end
        inner_object.save
      end
    end
  end
      
end


ActiveRecord::Base.send :include, ActsAsElibriProduct
