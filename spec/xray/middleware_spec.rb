require 'spec_helper'

describe Xray::Middleware do
  it "injects xray.js into the response" do
    visit '/'
    expect(page.html).to include('xray.js')
  end

  it "injects the xray bar into the response" do
    visit '/'
    expect(page).to have_selector('#xray-bar')
  end

  it "does not add html comments to json.haml pages" do
    visit '/made_with_haml.json'
    expect(page.html).not_to include('<!--XRAY START')
  end

  it "doesn't mess with non-html requests" do
    visit '/non_html'
    expect(page.html).not_to include('xray.js')
    expect(page).not_to have_selector('#xray-bar')
  end
end
