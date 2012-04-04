$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_elibri_product/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_elibri_product"
  s.version     = ActsAsElibriProduct::VERSION
  s.authors     = ["Piotr Szmielew"]
  s.email       = ["p.szmielew@ava.waw.pl"]
  s.homepage    = "http://elibri.com.pl"
  s.summary     = "Easy addition of eLibri based product to your application"
  s.description = "Gem designed to allow easy addition of eLibri based product to your application. Currently only tested under REE."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
#  s.add_dependency "elibri_xml_versions"
#  s.add_development_dependency "elibri_onix_mocks"

  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"

  s.add_development_dependency "sqlite3"
end
