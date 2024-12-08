require 'spec_helper'

describe Xray, "in a Rails app (end-to-end)", :js do
  it "works" do
    visit '/'
    expect_to_work
  end

  if Gem.loaded_specs['rails'].version >= Gem::Version.new('5.2.0')
    it "works when using a strict CSP" do
      visit '/strict_csp'
      expect_to_work
    end
  end

  def expect_to_work
    if Gem.loaded_specs['rails'].version >= Gem::Version.new('5.2.0')
      expect(page).to have_selector('script[src^="/assets/xray"][nonce]')
      expect(page.find('script[src^="/assets/xray"]')[:nonce]).to eq page.find('meta[name="csp-nonce"]')[:content]
    end
    expect(page).to have_selector('#xray-bar')

    expect(page).to have_no_selector('.xray-specimen-handle.TemplateSpecimen', text: 'root.html.erb')
    find('body').send_keys [:control, :shift, 'x']
    expect(page).to have_selector('.xray-specimen-handle.TemplateSpecimen', text: 'root.html.erb')
  end
end unless ENV['CI'] == 'true'
