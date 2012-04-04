# == Schema Information
#
# Table name: products
#
#  id                 :integer(4)      not null, primary key
#  record_reference   :string(255)     not null
#  isbn               :string(255)
#  title              :string(255)
#  full_title         :string(255)
#  trade_title        :string(255)
#  original_title     :string(255)
#  publication_year   :integer(4)
#  publication_month  :integer(4)
#  publication_day    :integer(4)
#  number_of_pages    :integer(4)
#  duration           :integer(4)
#  width              :integer(4)
#  height             :integer(4)
#  cover_type         :string(255)
#  edition_statement  :string(255)
#  audience_age_from  :integer(4)
#  audience_age_to    :integer(4)
#  price_amount       :string(255)
#  vat                :integer(4)
#  pkwiu              :string(255)
#  current_state      :string(255)
#  product_form       :string(255)
#  preview_exists     :boolean(1)      default(FALSE)
#  no_contributor     :boolean(1)      default(FALSE)
#  unnamed_persons    :boolean(1)      default(FALSE)
#  created_at         :datetime        not null
#  updated_at         :datetime        not null
#  cover_file_name    :string(255)
#  cover_content_type :string(255)
#  cover_file_size    :integer(4)
#  cover_updated_at   :datetime
#

class Product < ActiveRecord::Base

  with_options :autosave => true, :dependent => :destroy do |product|
    product.has_many :contributors
    product.has_many :product_texts
    product.has_one :imprint
  end

  attr_accessible :isbn, :title, :full_title, :trade_title, :original_title, :publication_year,
                  :publication_month, :publication_day, :number_of_pages, :width, :height, 
                  :cover_type, :edition_statement, :audience_age_from, :audience_age_to, 
                  :price_amount, :vat, :current_state, :product_form, :old_xml
                  
  #po lewej stronie to co w elibri, po prawej co ma być w naszej bazie               
  acts_as_elibri_product :record_reference => :record_reference,
         :isbn13 => :isbn,
         :title => :title,
         :full_title => :full_title,
         :trade_title => :trade_title,
         :original_title => :original_title,
         :number_of_pages => :number_of_pages,
         :duration => :duration,
         :width => :width,
         :height => :height,
         :cover_type => :cover_type,
         :pkwiu => :pkwiu,
         :edition_statement => :edition_statement,
         :reading_age_from => :audience_age_from,
         :reading_age_to => :audience_age_to,
         :cover_price => :price_amount,
         :vat => :vat,
         :product_form => :product_form,
         :no_contributor? => :no_contributor,
         :unnamed_persons? => :unnamed_persons,
         :contributors => { #Jak się nazywa w eLibri
           :contributors => { #Jak się nazywa w naszej bazie
             :id => :import_id, #przeksztalcenie nazw atrybutow elibri => nasza baza
             :role_name => :role_name,
             :role => :role,
             :from_language => :from_language,
             :person_name => :full_name,
             :titles_before_names => :title,
             :names_before_key => :first_name,
             :prefix_to_key => :last_name_prefix,
             :key_names => :last_name,
             :names_after_key => :last_name_postfix,
             :biographical_note => :biography
           }
         },
         :text_contents => { #Jak się nazywa w eLibri
           :product_texts => { #Jak się nazywa w naszej bazie
             :id => :import_id, #przeksztalcenie nazw atrybutow elibri => nasza baza
             :text => :text,
             :type_name => :text_type,
             :author => :text_author,
             :source_title => :source_title,
             :source_url => :resource_link
           }
         },
         :imprint => { #Jak się nazywa w eLibri
           :imprint => { #Jak się nazywa w naszej bazie
             :name => :name #przeksztalcenie nazw atrybutow elibri => nasza baza
           }
         }
         
  def self.batch_update(products, dialect)
    #products - response.onix.products dajemy tam wyzej
    #response.onix.elibri_dialect
    products.each do |product|
      xml = product.to_xml.to_s
  
      ### używany dialekt

      ### żeby odtworzyć powyższy obiekt z xml-a:
      header = "<?xml version='1.0' encoding='UTF-8'?>
                <ONIXMessage xmlns:elibri='http://elibri.com.pl/ns/extensions' xmlns='`http://www.editeur.org/onix/3.0/reference' release='3.0'>
                    <elibri:Dialect>#{dialect}</elibri:Dialect>"

      xml = header + xml + "</ONIXMessage>"
      recreated_product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(xml).products.first
      
      if Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference})
        #robimy diffa
        Product.find(:first, :conditions => {:record_reference => recreated_product.record_reference}).update_product_from_elibri(xml)
      else
        #tworzymy nowy produkt
        db_product = Product.new
        db_product.record_reference = product.record_reference
        db_product.isbn = product.isbn13
        db_product.title = product.title
        db_product.full_title = product.full_title
        db_product.trade_title = product.trade_title
        db_product.original_title = product.original_title
        db_product.number_of_pages = product.number_of_pages
        db_product.duration = product.duration
        db_product.width = product.width
        db_product.height = product.height
        db_product.cover_type = product.cover_type
        db_product.pkwiu = product.pkwiu
        db_product.edition_statement = product.edition_statement
        db_product.audience_age_from = product.reading_age_from
        db_product.audience_age_to = product.reading_age_to
        db_product.price_amount = product.cover_price
        db_product.vat = product.vat
        db_product.product_form = product.product_form
        db_product.no_contributor = product.no_contributor?
        db_product.unnamed_persons = product.unnamed_persons?
        db_product.old_xml = xml
        db_product.save
        
      end
      
    end
    
    
  end  

end
