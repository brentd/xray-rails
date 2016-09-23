# -*- encoding: utf-8 -*-
require File.expand_path('../lib/xray/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "xray-rails"
  gem.authors       = ["Brent Dillingham"]
  gem.email         = ["brentdillingham@gmail.com"]
  gem.summary       = %q{Reveal the structure of your UI}
  gem.description   = %q{Provides a dev bar and an overlay in-browser to visualize your UI's rendered partials and Backbone views}
  gem.homepage      = "https://github.com/brentd/xray-rails"

  gem.files         = Dir['{app,lib}/**/*'] + ['LICENSE', 'README.md']
  gem.require_paths = ["lib"]
  gem.version       = Xray::VERSION
  gem.license       = 'MIT'

  gem.post_install_message = <<-MESSAGE
Backbone.js support will be removed from xray-rails in version 0.2.0.
If you need backbone.js support, lock xray-rails to 0.1.22 to avoid breaking changes.
MESSAGE

  gem.add_dependency 'rails', '>= 3.1.0'
  gem.add_dependency 'coffee-rails'

  gem.add_development_dependency 'rspec-rails'
  # Required for the dummy Rails app in spec/dummy
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'jquery-rails'
  gem.add_development_dependency 'backbone-rails'
  gem.add_development_dependency 'sass-rails'
  gem.add_development_dependency 'haml'
  gem.add_development_dependency 'eco'
  gem.add_development_dependency 'capybara'
end
