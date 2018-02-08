require 'spec_helper'

describe "Xray Bar" do
  before { visit '/' }

  it "includes the controller and action" do
    expect(find('#xray-bar')).to have_text('ApplicationController#root')
  end

  it "includes the layout used" do
    expect(find('#xray-bar')).to have_text('application.html.erb')
  end

  it "includes the view rendered" do
    expect(find('#xray-bar')).to have_text('root.html.erb')
  end
end
