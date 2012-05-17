[![Build Status](https://secure.travis-ci.org/elibri/acts_as_elibri_product.png?branch=master)](http://travis-ci.org/elibri/acts_as_elibri_product)

Gem designed to allow easy addition of eLibri based product to your application.

Working under 1.8 version of Ruby.

Usage guide:  

* Add `'acts_as_elibri_product'` to your Gemfile

* Run `rails g add_acts_as_elibri_product [YOUR_PRODUCT_MODEL_NAME]`

* Run `rake db:migrate`

* Add `acts_as_elibri_product TRAVERSE_VECTOR` to your product_model

* Schedule (for example in cron) regular calls to `ProductModel.batch_create_or_update_from_elibri` providing `xml_string` from eLibri API as an argument, or providing `Elibri::ONIX::Release_3_0::ONIXMessage` from eLibri API as an argument.

TRAVERSE_VECTOR is a structure containing information about mapping elibri arguments to your model arguments. Attributes not specified here, will be ignored during data import.

Structure is build using hashes, general rule is:  
```ruby
{
:elibri_attribute_name => :application_attribute_name,  
:another_elibri_attribute_name => :another_application_attribute_name
}
```

Also you can use lambda in this construction, if you want to do something with attribute (for example downcase it).
In this case, you should use array, where first element is name of elibri attribute and second element is lambda that describes what to do with it.

Example:
```ruby
{
  :title => [:title, lambda {|x| Logger.info("changing title"); return "#{x}_test"}]
} 

Important thing is that lambda need to take exactly one argument, and need to return final value of attribute to write into database.
Also very important thing is that lambdas are now supported only on first level of vector (not in embedded hashes).

If you want to use lambda, but don't write anything to database, you should use nil as first attribute in array. For example:
```ruby
{
 :title => [nil, lambda {|x| Logger.info("changing title"); return "#{x}_test"}]
}

When dealing with embedded objects and relations, you should use embedded hashes:  

```ruby
:elibri_embedded_object_name =>  
  { :application_relations_name =>    
    {  
      :embedded_object_elibri_attribute_name => :application_relation_object_attribute_name,  
      :another_embedded_object_elibri_attribute_name => :another_application_relation_object_attribute_name     
    }      
  }
```

In embedded object, id may change, however import_id and/or record_reference will always remain unchanged.
  
example vector:

```ruby
:record_reference => :record_reference,
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
:contributors => { #embedded name in elibri
 :contributors => { #embedded name in elibri
   :id => :import_id, #name transition atrybutow elibri => our app
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
:text_contents => { #embedded name in elibri
 :product_texts => { #embedded name in elibri
   :id => :import_id, #name transition atrybutow elibri => our app
   :text => :text,
   :type_name => :text_type,
   :author => :text_author,
   :source_title => :source_title,
   :source_url => :resource_link
 }
},
:imprint => {
 :imprint => {
   :name => :name
 }
}
```

Also if you want to check for some particular changes in object - you can use policy chain.

```
policy_chain << PolicyObject
policy_chain << lambda
```

PolicyObject must implement class method call, which take four arguments:

* object is symbol of object that inside which attribute is changing - it should be our name, not elibri one, for example on main level it would :product, inside contributors it will be :contributors etc.

* attribute is symbol of attribute that will change - it should be our name, not elibri one

* pre - value of attribute before potential update

* post - value of attribute after potential update

Also policy must return one of two values - true (if allow of changing an attribute) or false (if attribute should remain unchanged). You can implement notification etc inside Policy, when attribute is discarded - it's up to you.

example of Policy (stub):
```ruby
module Policy #module is optional - however it is good practice to keep all policies in Policy module, and in subdirectory inside lib
  class Stub
  
    def self.call(object, attribute, pre, post)
      ### Add policy body here
      return true
    end
  
  end
end

example of adding policy lambda:
```ruby
policy_chain << lambda do |object, attribute, pre, post|
   if object == :product
     if attribute == :price_amount
       return false unless pre == post #won't allow change of product price
     end
   end
   return true
 end
```