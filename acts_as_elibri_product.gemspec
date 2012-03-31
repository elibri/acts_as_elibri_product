$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "acts_as_elibri_product/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "acts_as_elibri_product"
  s.version     = ActsAsElibriProduct::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of ActsAsElibriProduct."
  s.description = "TODO: Description of ActsAsElibriProduct."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.0"
#  s.add_dependency "elibri_xml_versions", :path => '/Users/esse/work/gildia/elibri_xml_versions'
#  s.add_development_dependency "elibri_onix_mocks", :path => '/Users/esse/work/gildia/elibri_xml_versions'

  s.add_development_dependency "sqlite3"
end
