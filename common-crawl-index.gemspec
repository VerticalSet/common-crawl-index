# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'common-crawl-index/version'

Gem::Specification.new do |gem|
  gem.name          = "common-crawl-index"
  gem.version       = CommonCrawlIndex::VERSION
  gem.authors       = ["Amit Ambardekar"]
  gem.email         = ["amitamb@gmail.com"]
  gem.description   = %q{Access coomon crawl URL index}
  gem.summary       = %q{Access coomon crawl URL index}
  gem.homepage      = "https://github.com/VerticalSet/common-crawl-index"

  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency('aws-sdk')
  gem.add_runtime_dependency('addressable')
end
