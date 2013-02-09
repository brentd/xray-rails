require "x-ray/version"
require "open3"

module Xray
  CONSTRUCTOR_REGEX = /^([\s]*)(?!_)([\w\.]+)\s*\=\s*(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

  def self.augment_application_js(source, path)
    source.gsub(/(\/\/|#)\s*\=\s*require jquery\s*$/) do
      "#{$1}= require jquery\n#{$1}= require x-ray"
    end
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
    case source
    when ActiveSupport::SafeBuffer
      ActiveSupport::SafeBuffer.new(augmented)
    else
      augmented
    end
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
      # Xray.start_server
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

      APP_JS_PATH = "#{app.root}/app/assets/javascripts/application.js" # TODO: don't hardcode this?

      # Augment javascript templates as a preprocessor
      app.assets.register_preprocessor 'application/javascript', :xray do |context, data|
        path = context.pathname.to_s
        if path.starts_with?(APP_JS_PATH)
          Xray.augment_application_js(data, path)
        elsif path =~ /\.(jst|hamlc)(\.|$)/
          Xray.augment_template(data, path)
        else
          data
        end
      end

      # Move our preprocessor in front of Sprocket's directive processor.
      # FIXME: this sucks, but there's no public API - it's either this or alias_method_chain.
      app.assets.instance_variable_get(:@preprocessors)['application/javascript'].tap do |procs|
        procs.unshift procs.delete_at(procs.count-1)
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
    end
  end
end