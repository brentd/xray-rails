require 'spec_helper'
require File.expand_path("../../dummy/config/environment", __FILE__)
require 'rspec/rails'

describe Xray::Middleware, type: :request do
  it "injects xray.js into the response" do
    get '/'
    puts response.body
  end
end
