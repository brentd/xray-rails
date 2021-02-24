require 'spec_helper'

describe Xray, "in a Rails app (end-to-end)", :js do
  it "works" do
    visit '/'
    expect_to_work
  end

  def expect_to_work
    expect(page).to have_selector('#xray-bar')

    expect(page).to have_no_selector('.xray-specimen-handle.TemplateSpecimen', text: 'root.html.erb')
    find('body').send_keys [:control, :shift, 'x']
    expect(page).to have_selector('.xray-specimen-handle.TemplateSpecimen', text: 'root.html.erb')
  end
end unless ENV['CI'] == 'true'
