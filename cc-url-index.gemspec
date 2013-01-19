# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cc-url-index/version'

Gem::Specification.new do |gem|
  gem.name          = "cc-url-index"
  gem.version       = Cc::Url::Index::VERSION
  gem.authors       = ["Amit Ambardekar"]
  gem.email         = ["amitamb@gmail.com"]
  gem.description   = %q{Access coomon crawl URL index}
  gem.summary       = %q{Access coomon crawl URL index}
  gem.homepage      = ""

  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
