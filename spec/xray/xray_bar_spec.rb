require 'spec_helper'

describe "Xray Bar" do
  before { visit '/' }

  it "includes the controller and action" do
    find('#xray-bar').should have_text('ApplicationController#root')
  end

  it "includes the layout used" do
    find('#xray-bar').should have_text('application.html.erb')
  end

  it "includes the view rendered" do
    find('#xray-bar').should have_text('root.html.erb')
  end
end
