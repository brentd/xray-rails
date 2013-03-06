require "xray/version"
require "open3"

module Xray
  CONSTRUCTOR_REGEX = /^( *)(?!_)([\w\.]+) *= *(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

  def self.request_info
    @request_info ||= {}
  end

  def self.augment_js(source, path)
    source.gsub(CONSTRUCTOR_REGEX) do
      space, class_name, func = $1, $2, $3
      info = {name: class_name, path: path.to_s}
      xray = "(window.XrayPaths||(window.XrayPaths={}))['#{info.to_json}']"
      "#{space}#{class_name} = #{xray} = #{func}"
    end
  end

  def self.augment_template(source, path)
    id = next_id
    augmented = "<!-- XRAY START #{id} #{path} -->\n#{source}\n<!-- XRAY END #{id} -->"
    ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
  end

  def self.next_id
    cur_id = (@id ||= 1)
    @id += 1
    cur_id
  end

  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] == '/xray/open'
        req, res = Rack::Request.new(env), Rack::Response.new
        out, err, status = Open3.capture3('/usr/local/bin/subl', req.GET['path'])
        if status.success?
          res.status = 200
        else
          res.write out
          res.status = 500
        end
        res.finish
      else
        status, headers, response = @app.call(env)
        return [status, headers, response] if file?(headers) || empty?(response)

        if status == 200 && !response.body.frozen? && html_request?(headers, response)
          body = response.body.sub(/<body.*>/) { "#{$~}\n#{xray_content}" }
          append_js!(body, 'jquery', :xray)
          append_js!(body, 'backbone', :'xray-backbone')
          headers['Content-Length'] = body.bytesize.to_s
        end
        [status, headers, body ? [body] : response]
      end
    end

    private

    def xray_content
      ActionController::Base.new.render_to_string(:partial => 'shared/xray_bar').html_safe
    end

    def append_js!(html, after_script_name, script_name)
      html.sub!(/<script.+#{after_script_name}([-.]{1}[\d\.]+)?([-.]{1}min)?\.js.+><\/script>/) do
        "#{$~}\n" + ActionController::Base.helpers.javascript_include_tag(script_name)
      end
    end

    def js(name)
      ActionController::Base.helpers.javascript_include_tag(name)
    end

    # fix issue if response's body is a Proc
    def empty?(response)
      # response may be ["Not Found"], ["Move Permanently"], etc.
      (response.is_a?(Array) && response.size <= 1) ||
        !response.respond_to?(:body) || response.body.empty?
    end

    # if send file?
    def file?(headers)
      headers["Content-Transfer-Encoding"] == "binary"
    end

    def html_request?(headers, response)
      headers['Content-Type'] && headers['Content-Type'].include?('text/html') && response.body.include?("<html")
    end
  end

  class Engine < ::Rails::Engine
    paths['app/assets'] = 'lib/assets'

    initializer "xray.initialize" do |app|
      app.middleware.use Xray::Middleware

      # Augment JS files, including compiled coffeescript
      app.assets.register_postprocessor 'application/javascript', :xray do |context, data|
        path = context.pathname.to_s
        if path =~ /\.(js|coffee)(\.|$)/
          Xray.augment_js(data, path)
        elsif path =~ /\.(jst|hamlc)(\.|$)/
          Xray.augment_template(data, path)
        else
          data
        end
      end

      # Augment templates
      ActionView::Template.class_eval do
        def render_with_xray(*args, &block)
          path = identifier
          source = render_without_xray(*args, &block)
          if path !~ /xray_bar\./
            Xray.augment_template(source, path)
          else
            source
          end
        end
        alias_method_chain :render, :xray
      end

      ActiveSupport::Notifications.subscribe('start_processing.action_controller') do |*args|
        event           = ActiveSupport::Notifications::Event.new(*args)
        controller_name = event.payload[:controller]
        action_name     = event.payload[:action]
        path            = ActiveSupport::Dependencies.search_for_file(controller_name.underscore)
        Xray.request_info.clear
        Xray.request_info[:controller] = {
          :path   => path,
          :name   => controller_name,
          :action => action_name
        }
      end

      ActiveSupport::Notifications.subscribe('render_template.action_view') do |*args|
        event = ActiveSupport::Notifications::Event.new(*args)
        Xray.request_info[:view] = {
          :path   => event.payload[:identifier],
          :layout => event.payload[:layout]
        }
      end
    end
  end
end