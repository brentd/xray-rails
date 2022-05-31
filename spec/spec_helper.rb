require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rspec'

class String
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "").chomp!
  end
end

RSpec.configure do |config|
  config.include Capybara::DSL
  config.include Capybara::RSpecMatchers
end
Dir[Pathname.new(__dir__).join('support/**/*.rb')].each {|f| require f}

Capybara.configure do |config|
  config.ignore_hidden_elements = false
  config.javascript_driver = :selenium_headless
end
