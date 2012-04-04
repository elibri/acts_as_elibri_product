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
    lambda do
      Product.batch_create_or_update_from_elibri(book_xml)
    end.should_not change(Product.first, 'created_at')
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
  
  it "should create and update two products from xml containing two products with authors" do
    Product.count.should eq(0)
    contributor = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Mickiewicz', :name => 'Adam', :artificial_id => 123)
    contributor_2 = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Sienkiewicz', :name => 'Henryk', :artificial_id => 124)
    contributor_3 = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Orwell', :name => 'George', :artificial_id => 125)
    contributor_4 = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Prus', :name => 'Bolesław', :artificial_id => 126)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890', :contributors => [contributor])
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '9876543210', :contributors => [contributor_2])
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.all.map(&:record_reference).should include('abcd')
    Product.all.map(&:record_reference).should include('abcde')
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('1234567890')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('9876543210')
    Contributor.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.first.first_name.should eq("Adam")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.first.last_name.should eq("Mickiewicz")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.first.first_name.should eq("Henryk")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.first.last_name.should eq("Sienkiewicz")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.count.should eq(1)
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.count.should eq(1)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210', :contributors => [contributor_3])
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '1234567890', :contributors => [contributor_4])
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('9876543210')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('1234567890')
    Contributor.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.first.first_name.should eq("George")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.first.last_name.should eq("Orwell")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.first.first_name.should eq("Bolesław")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.first.last_name.should eq("Prus")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).contributors.count.should eq(1)
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).contributors.count.should eq(1)
  end
 
  it "should create and update two products from xml containing two products with description" do
    Product.count.should eq(0)
    description = Elibri::XmlMocks::Examples.description_mock(:text_author => 'Mickiewicz', :artificial_id => 123)
    description_2 = Elibri::XmlMocks::Examples.description_mock(:text_author => 'Sienkiewicz', :artificial_id => 124)
    description_3 = Elibri::XmlMocks::Examples.description_mock(:text_author => 'Orwell', :artificial_id => 125)
    description_4 = Elibri::XmlMocks::Examples.description_mock(:text_author => 'Prus', :artificial_id => 126)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '1234567890', :other_texts => [description])
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '9876543210', :other_texts => [description_2])
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.all.map(&:record_reference).should include('abcd')
    Product.all.map(&:record_reference).should include('abcde')
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('1234567890')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('9876543210')
    ProductText.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).product_texts.first.text_author.should eq("Mickiewicz")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).product_texts.first.text_author.should eq("Sienkiewicz")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).product_texts.count.should eq(1)
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).product_texts.count.should eq(1)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :isbn_value => '9876543210', :other_texts => [description_3])
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :isbn_value => '1234567890', :other_texts => [description_4])
    book_array = [book, book_2]
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    lambda do
      lambda do
        Product.batch_create_or_update_from_elibri(book_xml)
      end.should_not change(Product.find(:first, :conditions => {:record_reference => 'abcd'}), 'created_at')
    end.should_not change(Product.find(:first, :conditions => {:record_reference => 'abcde'}), 'created_at')
    Product.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).isbn.should eq('9876543210')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).isbn.should eq('1234567890')
    ProductText.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).product_texts.first.text_author.should eq("Orwell")
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).product_texts.first.text_author.should eq("Prus")
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).product_texts.count.should eq(1)
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).product_texts.count.should eq(1)
  end
  
  it "should create product when given new xml with imprint" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :imprint => Elibri::XmlMocks::Examples.imprint_mock(:name => 'Helion'))
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(book_xml).products.first
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.imprint.name.should eq("Helion")
    Imprint.count.should eq(1)
  end
  
  it "should create and update product when given new xml with imprint" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :imprint => Elibri::XmlMocks::Examples.imprint_mock(:name => 'Helion'))
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(book_xml).products.first
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.imprint.name.should eq("Helion")
    Imprint.count.should eq(1)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :imprint => Elibri::XmlMocks::Examples.imprint_mock(:name => 'GREG'))
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(book_xml).products.first
    lambda do
      Product.batch_create_or_update_from_elibri(book_xml)
    end.should_not change(Imprint.first, :created_at)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.imprint.name.should eq("GREG")
    Imprint.count.should eq(1)
  end

  
end