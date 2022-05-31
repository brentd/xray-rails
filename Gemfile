source 'https://rubygems.org'
gemspec

if ENV['RAILS_VERSION']
  gem 'rails', ENV['RAILS_VERSION']
  if ENV['RAILS_VERSION'][/\d.*/] >= '6.0.0'
    # use latest (4.x)
  else
    gem 'sprockets', '~> 3.0'
  end
end

if (local_file = Pathname('Gemfile.local')).exist?
  eval local_file.read, binding, __FILE__, __LINE__
end
