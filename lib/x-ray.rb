require "x-ray/version"
require "open3"

module Xray
  CONSTRUCTOR_REGEX = /^([\s]*)(?!_)([\w\.]+)\s*\=\s*(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

  def self.request_info
    @request_info ||= {}
  end

  def self.augment_js(source, path)
    source.gsub(CONSTRUCTOR_REGEX) do
      space, class_name, func = $1, $2, $3
      info = {name: class_name, path: path.to_s}
      xray = "(window.XrayData||(window.XrayData={}))['#{info.to_json}']"
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
        @app.call(env)
      end
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
        else
          data
        end
      end

      # TODO: How can I not hardcode these?
      APP_JS_PATH  = "#{app.root}/app/assets/javascripts/application."
      APP_CSS_PATH = "#{app.root}/app/assets/stylesheets/application."

      app.assets.register_preprocessor 'application/javascript', :xray do |context, data|
        path = context.pathname.to_s
        if path =~ /\/backbone\.js$/ # TODO: directly augment backbone instead to avoid load order crap
          context.require_asset('x-ray.js')
        elsif path =~ /\.(jst|hamlc)(\.|$)/
          data = Xray.augment_template(data, path)
        end
        data
      end

      app.assets.register_preprocessor 'text/css', :xray_css do |context, data|
        path = context.pathname.to_s
        if path.starts_with?(APP_CSS_PATH)
          context.require_asset('xray.css')
        end
        data
      end

      # Augment templates
      ActionView::Template.class_eval do
        def render_with_xray(*args, &block)
          path = identifier
          source = render_without_xray(*args, &block)
          Xray.augment_template(source, path)
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