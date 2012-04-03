require 'spec_helper'

#silencing warnings from comparer
$VERBOSE = nil

describe ActsAsElibriProduct do
  
  it "should create product when given new xml with contributor" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :contributors => [Elibri::XmlMocks::Examples.contributor_mock])
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(book_xml).products.first
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Contributor.count.should eq(1)
  end
  
  it "should create and update product with same record_reference" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890', :contributors => [Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Mickiewicz', :name => 'Adam', :artificial_id => 123)])
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.first.isbn.should eq("1234567890")
    Product.count.should eq(1)
    Product.first.contributors.first.first_name.should eq("Adam")
    Product.first.contributors.first.last_name.should eq("Mickiewicz")
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210', :contributors => [Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Sienkiewicz', :name => 'Henryk', :artificial_id => 123)]) 
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.isbn.should eq("9876543210")
    Product.first.contributors.first.first_name.should eq("Henryk")
    Product.first.contributors.first.last_name.should eq("Sienkiewicz")
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
  
  it "should create and update two products from xml containing two products" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890')
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '9876543210')
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.all.map(&:record_reference).should include('abcd')
    Product.all.map(&:record_reference).should include('abcde')
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('1234567890')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('9876543210')
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210')
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '1234567890')
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('9876543210')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('1234567890')
  end
  
end