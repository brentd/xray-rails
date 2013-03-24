# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xray/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "xray-rails"
  gem.authors       = ["Brent Dillingham"]
  gem.email         = ["brentdillingham@gmail.com"]
  gem.summary       = %q{Visualize and edit your app's UI structure}
  gem.description   = %q{Provides a dev bar and an overlay in-browser to visualize your UI's rendered partials and Backbone views}
  gem.homepage      = "https://github.com/brentd/xray-rails"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.version       = Xray::VERSION

  gem.add_dependency 'coffee-rails'
end
