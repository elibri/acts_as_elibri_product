# -*- encoding : utf-8 -*-
#encoding: UTF-8
require 'spec_helper'

#silencing warnings from comparer
$VERBOSE = nil



describe ActsAsElibriProduct do

  it "should raise an exception when given product with empty old_xml" do
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :contributors => [Elibri::XmlMocks::Examples.contributor_mock])
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    product = Elibri::ONIX::Release_3_0::ONIXMessage.from_xml(book_xml).products.first
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Contributor.count.should eq(1)
    Product.first.update_attribute(:old_xml, nil)
    lambda { Product.batch_create_or_update_from_elibri(book_xml) }.should raise_error
  end

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

  it "should create products from xml and change data with lambda" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :title => 'UML')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.title.should eq("UML_test")
    Product.first.record_reference.should eq("abcd")
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :title => 'UML2')
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.title.should eq("UML2_test")
    Product.first.record_reference.should eq("abcd")
  end
  
  it "should not set field number_of_pages from xml with lambda (but should call this lambda)" do
    Product.count.should eq(0)
    book = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :number_of_pages => 125)
    book_xml = Elibri::ONIX::XMLGenerator.new(book).to_s
    Product.tester = 0
    Product.tester.should eq(0)
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.tester.should eq(125)
    Product.count.should eq(1)
    Product.first.record_reference.should eq("abcd")
    Product.first.number_of_pages.should eq(nil)
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
  
  it "should create and update product when given new xml containing two products - both with imprint" do
    Product.count.should eq(0)
    imprint_1 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'Helion')
    imprint_2 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'GREG')
    imprint_3 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'Czarna Owca')
    imprint_4 = Elibri::XmlMocks::Examples.imprint_mock(:name => 'WNT')
    book_1 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :imprint => imprint_1)
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :imprint => imprint_2)  
    book_array = [book_1, book_2]  
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).imprint.name.should eq('Helion')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).imprint.name.should eq('GREG')
    Imprint.count.should eq(2)
    book_1 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :imprint => imprint_3)
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcde', :imprint => imprint_4)  
    book_array = [book_1, book_2]  
    book_xml = Elibri::ONIX::XMLGenerator.new(book_array).to_s
    lambda do
      Product.batch_create_or_update_from_elibri(book_xml)
    end.should_not change(Imprint.first, :created_at)
    Product.count.should eq(2)
    Product.find(:first, :conditions => {:record_reference => 'abcd'}).imprint.name.should eq('Czarna Owca')
    Product.find(:first, :conditions => {:record_reference => 'abcde'}).imprint.name.should eq('WNT')
    Imprint.count.should eq(2)
  end
  
  it "should change author data when author changes" do
    author = Elibri::XmlMocks::Examples.contributor_mock(:id => 2167055520)
    author_2 = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Waza', :id => 2167055520)
    book_1 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'fdb8fa072be774d97a97', :contributors => [author])
    book_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'fdb8fa072be774d97a97', :contributors => [author_2])
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("fdb8fa072be774d97a97")
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Product.first.contributors.first.first_name.should eq("Henryk")
    Product.first.contributors.first.last_name.should eq("Sienkiewicz")
    book_xml = Elibri::ONIX::XMLGenerator.new(book_2).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("fdb8fa072be774d97a97")
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Product.first.contributors.first.first_name.should eq("Henryk")
    Product.first.contributors.first.last_name.should eq("Waza")
  end
  
  it "policy_chain should not allow to update of cover_price (price_amount)" do
    book_1 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :price_amount => 25)
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.first.record_reference.should eq("abcd")
    Product.count.should eq(1)
    Product.first.price_amount.should eq("25.0")
    book_1 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'abcd', :price_amount => 30)
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s  
    Product.batch_create_or_update_from_elibri(book_xml)  
    Product.first.price_amount.should eq("25.0")
  end
  
  it "policy_chain should not allow to update of contributor inside product when changing name from Adam to Adas" do
    author = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Adam', :id => 2167055520)
    book_1 = Elibri::XmlMocks::Examples.book_example(:contributors => [author], :record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Contributor.count.should eq(1)
    Contributor.first.last_name.should eq('Adam')
    author = Elibri::XmlMocks::Examples.contributor_mock(:last_name => 'Adas', :id => 2167055520)
    book_1 = Elibri::XmlMocks::Examples.book_example(:contributors => [author], :record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)  
    Product.count.should eq(1)
    Product.first.contributors.count.should eq(1)
    Contributor.count.should eq(1)
    Contributor.first.last_name.should eq('Adam')
  end
  
  it "should create and update properly product with front_cover" do
    attachment = Elibri::XmlMocks::Examples.product_attachment_mock(:file => Elibri::XmlMocks::Examples.paperclip_attachment_mock(:url => 'http://example.com/pic.jpg'))
    book_1 = Elibri::XmlMocks::Examples.book_example(:attachments => [attachment], :record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.cover_link.should eq('http://example.com/pic.jpg')
    attachment = Elibri::XmlMocks::Examples.product_attachment_mock(:file => Elibri::XmlMocks::Examples.paperclip_attachment_mock(:url => 'http://example.com/pic2.jpg'))
    book_1 = Elibri::XmlMocks::Examples.book_example(:attachments => [attachment], :record_reference => 'abcd')
    book_xml = Elibri::ONIX::XMLGenerator.new(book_1).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.cover_link.should eq('http://example.com/pic2.jpg')
  end
  
  it "should create related products properly for product" do
    product = Elibri::XmlMocks::Examples.product_with_similars_mock
    book_xml = Elibri::ONIX::XMLGenerator.new(product).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(1)
    Product.first.related_products.count.should eq(2)
    Product.first.related_products[0].related_record_reference.should eq('fdb8fa072be774d97a95')
    Product.first.related_products[1].related_record_reference.should eq('fdb8fa072be774d97a98')
  end

  it "should create related products properly for product and later allow access to this products" do
    product_1 = Elibri::XmlMocks::Examples.product_with_similars_mock
    product_2 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'fdb8fa072be774d97a95', :title => 'UML_1')
    product_3 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'fdb8fa072be774d97a98', :title => 'UML_2')
    product_4 = Elibri::XmlMocks::Examples.book_example(:record_reference => 'fdb8fa072be774d97a80', :title => 'UML_3')
    products = [product_1, product_2, product_3, product_4]
    book_xml = Elibri::ONIX::XMLGenerator.new(products).to_s
    Product.batch_create_or_update_from_elibri(book_xml)
    Product.count.should eq(4)
    main = Product.where(:record_reference => 'fdb8fa072be774d97a99').first
    main.related_products.count.should eq(2)
    main.related_products[0].related_record_reference.should eq('fdb8fa072be774d97a95')
    main.related_products[1].related_record_reference.should eq('fdb8fa072be774d97a98')
    main.related_products[0].object.title.should eq('UML_1_test')
    main.related_products[1].object.title.should eq('UML_2_test')
    main.related_products[0].onix_code.should eq('24')
    main.related_products[1].onix_code.should eq('24')
    main.related_products.objects.count.should eq(2)
    main.related_products.objects[0].title.should eq('UML_1_test')
    main.related_products.objects[1].title.should eq('UML_2_test')
    main.related_products.objects[0].record_reference.should eq('fdb8fa072be774d97a95')
    main.related_products.objects[1].record_reference.should eq('fdb8fa072be774d97a98')
  end
  
end
