# -*- encoding: utf-8 -*-
require File.expand_path('../lib/downloader/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tomas Svarovsky"]
  gem.email         = ["svarovsky.tomas@gmail.com"]
  gem.description   = %q{Tza best downloader in da hood bitch}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "downloader"
  gem.require_paths = ["lib"]
  gem.version       = Downloader::VERSION
  gem.add_dependency('pry')
end
