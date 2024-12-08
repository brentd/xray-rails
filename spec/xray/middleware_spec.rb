require 'spec_helper'

describe Xray::Middleware, "in a middleware stack" do
  def mock_response(status, content_type, body)
    body = body.unindent
    app = Rack::Builder.new do
      use Xray::Middleware
      run lambda { |env| [status, {'Content-Type' => content_type}, [body]] }
    end
    Rack::MockRequest.new(app).get('/')
  end

  context "when the response is html and contains <body>" do
    it "injects the xray bar and xray.js" do
      response = mock_response 200, 'text/html', <<-HTML
        <html>
          <head>
            <script src=\"/assets/jquery.js\"></script>
          </head>
          <body></body>
        </html>
      HTML
      expect(response.body).to have_selector('#xray-bar')
      expect(response.body).to have_selector('script[src^="/assets/xray"]')
    end

    it "does not inject xray.js or the xray bar if jquery is not found" do
      response = mock_response 200, 'text/html', <<-HTML
        <html>
          <head></head>
          <body></body>
        </html>
      HTML
      expect(response.body).to_not have_selector('#xray-bar')
      expect(response.body).to_not have_selector('script[src^="/assets/xray"]')
    end

    it "does inject xray.js or the xray bar if jquery2 is found" do
      response = mock_response 200, 'text/html', <<-HTML
      <html>
        <head>
          <script src=\"/assets/jquery2.js\"></script>
        </head>
        <body></body>
      </html>
      HTML
      expect(response.body).to have_selector('#xray-bar')
      expect(response.body).to have_selector('script[src^="/assets/xray"]')
    end

    it "does inject xray.js or the xray bar if jquery3 is found" do
      response = mock_response 200, 'text/html', <<-HTML
      <html>
        <head>
          <script src=\"/assets/jquery3.js\"></script>
        </head>
        <body></body>
      </html>
      HTML
      expect(response.body).to have_selector('#xray-bar')
      expect(response.body).to have_selector('script[src^="/assets/xray"]')
    end
  end

  context "when the response does not contain <body>" do
    it "does not inject xray bar or xray.js" do
      response = mock_response 200, 'text/html', <<-HTML
        <div>just some html</div>
      HTML
      expect(response.body).to_not have_selector('#xray-bar')
      expect(response.body).to_not have_selector('script[src^="/assets/xray"]')
    end
  end

  context "when the response is blank" do
    it "does not inject xray" do
      response = mock_response 200, 'text/html', ''
      expect(response.body).to_not have_selector('#xray-bar')
      expect(response.body).to_not have_selector('script[src^="/assets/xray"]')
    end
  end

  context "when the response is unsuccessful" do
    it "does not inject xray" do
      response = mock_response 500, 'text/html', ''
      expect(response.body).to_not have_selector('#xray-bar')
      expect(response.body).to_not have_selector('script[src^="/assets/xray"]')
    end
  end
end

describe Xray::Middleware, "in a Rails app" do
  it "injects xray.js into the response" do
    visit '/'
    expect(page).to have_selector('script[src^="/assets/xray"]')
  end

  if Gem.loaded_specs['rails'].version >= Gem::Version.new('5.2.0')
    it "adds nonce to the script tag" do
      visit '/'
      expect(page).to have_selector('script[src^="/assets/xray"][nonce]')
      expect(page.find('script[src^="/assets/xray"]')[:nonce]).to eq page.find('meta[name="csp-nonce"]')[:content]
    end
  end

  it "injects the xray bar into the response" do
    visit '/'
    expect(page).to have_selector('#xray-bar')
  end

  it "doesn't mess with non-html requests" do
    visit '/non_html'
    expect(page.html).not_to include('xray')
    expect(page).not_to have_selector('#xray-bar')
  end

  context "edge cases" do
    it "does not add html comments to json.haml pages" do
      visit '/made_with_haml.json'
      expect(page.html).not_to include('<!--XRAY START')
    end

    it "does not add html comments to mailer templates" do
      mail = TestMailer.hello
      expect(mail.body.raw_source).not_to include('<!--XRAY START')
    end
  end
end
