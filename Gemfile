source 'https://rubygems.org'
gemspec

gem 'rails', ENV['RAILS_VERSION'] if ENV['RAILS_VERSION']

if (local_file = Pathname('Gemfile.local')).exist?
  eval local_file.read, binding, __FILE__, __LINE__
end
