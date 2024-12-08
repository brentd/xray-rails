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
  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end

Capybara.configure do |config|
  config.ignore_hidden_elements = false
end
