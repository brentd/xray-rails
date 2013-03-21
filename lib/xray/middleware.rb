require "open3"

module Xray
  OPEN_PATH = '/_xray/open'

  # This middleware is responsible for injecting xray.js, xray-backbone.js, and
  # the Xray bar into the app's pages. It also listens for requests to open files
  # with the user's editor.
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # Request for opening a file path.
      if env['PATH_INFO'] == OPEN_PATH
        req, res = Rack::Request.new(env), Rack::Response.new
        out, err, status = Open3.capture3('/usr/local/bin/subl', req.GET['path'])
        if status.success?
          res.status = 200
        else
          res.write out
          res.status = 500
        end
        res.finish

      # Inject xray.js and friends.
      else
        status, headers, response = @app.call(env)

        if should_inject_xray?(status, headers, response)
          body = response.body.sub(/<body[^>]*>/) { "#{$~}\n#{xray_bar}" }
          append_js!(body, 'jquery', :xray)
          append_js!(body, 'backbone', :'xray-backbone')
          headers['Content-Length'] = body.bytesize.to_s
        end
        [status, headers, body ? [body] : response]
      end
    end

    private

    def xray_bar
      ActionController::Base.new.render_to_string(:partial => '/xray_bar').html_safe
    end

    # Appends the given `script_name` after the `after_script_name`.
    def append_js!(html, after_script_name, script_name)
      # Matches:
      #   <script src="/assets/jquery.js"></script>
      #   <script src="/assets/jquery-min.js"></script>
      #   <script src="/assets/jquery.min.1.9.1.js"></script>
      html.sub!(/<script[^>]+#{after_script_name}([-.]{1}[\d\.]+)?([-.]{1}min)?\.js[^>]+><\/script>/) do
        h = ActionController::Base.helpers
        "#{$~}\n" + h.javascript_include_tag(script_name)
      end
    end

    def should_inject_xray?(status, headers, response)
      status == 200 &&
      html_request?(headers, response) &&
      !file?(headers) &&
      !empty?(response) &&
      !response.body.frozen?
    end

    def empty?(response)
      # response may be ["Not Found"], ["Move Permanently"], etc.
      (response.is_a?(Array) && response.size <= 1) ||
        !response.respond_to?(:body) || response.body.empty?
    end

    def file?(headers)
      headers["Content-Transfer-Encoding"] == "binary"
    end

    def html_request?(headers, response)
      headers['Content-Type'] && headers['Content-Type'].include?('text/html') && response.body.include?("<html")
    end
  end
end