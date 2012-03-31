require 'spec_helper'

describe ActsAsElibriProduct do
  
  it "should create product when given new xml" do
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
  end
  
  it "should create and update product with same record_reference" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.first.isbn.should eq("1234567890")
    Product.count.should eq(1)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210') 
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.isbn.should eq("9876543210")
  end
  
end