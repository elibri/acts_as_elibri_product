require 'spec_helper'

#silencing warnings from comparer
$VERBOSE = nil

describe ActsAsElibriProduct do
  
  it "should create product when given new xml" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
  end
  
  it "should create and update product with same record_reference" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.first.isbn.should eq("1234567890")
    Product.count.should eq(1)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210') 
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.isbn.should eq("9876543210")
  end
  
  it "should create two products from xml containing two products" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd')
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde')
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.all.map(&:record_reference).should include('abcd')
    Product.all.map(&:record_reference).should include('abcde')
  end
  
end