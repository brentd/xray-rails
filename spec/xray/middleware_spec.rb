require 'spec_helper'

describe Xray::Middleware, "in a simple middleware stack" do
  let(:app) {
    html = <<-HTML.unindent
      <html>
        <head>
          <script src=\"/assets/jquery.js\"></script>
        </head>
        <body></body>
      </html>
    HTML

    Rack::Builder.new do
      use Xray::Middleware
      run lambda { |env| [200, {'Content-Type' => "text/html"}, [html]] }
    end
  }

  def mock_request
    Rack::MockRequest.new(app)
  end

  it "should contain the xray bar" do
    response = mock_request.get('/')
    expect(response.body).to have_selector('#xray-bar')
    expect(response.body).to have_selector('script[src^="/assets/xray.js"]')
  end
end

describe Xray::Middleware, "in a Rails app" do
  it "injects xray.js into the response" do
    visit '/'
    expect(page).to have_selector('script[src^="/assets/xray.js"]')
  end

  it "injects the xray bar into the response" do
    visit '/'
    expect(page).to have_selector('#xray-bar')
  end

  it "doesn't mess with non-html requests" do
    visit '/non_html'
    expect(page.html).not_to include('xray.js')
    expect(page).not_to have_selector('#xray-bar')
  end

  context "edge cases" do
    it "does not add html comments to json.haml pages" do
      visit '/made_with_haml.json'
      expect(page.html).not_to include('<!--XRAY START')
    end
  end
end
