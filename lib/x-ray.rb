require "x-ray/version"
require 'sprockets'

module Xray
  CONSTRUCTOR_REGEX = /^([\s]*)(?!_)([\w\.]+)\s*\=\s*(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

  def self.augment_js(source, path)
    source.gsub(CONSTRUCTOR_REGEX) do
      space, class_name, func = $1, $2, $3
      info = {name: class_name, path: path.to_s}
      xray = "(window.XrayData||(window.XrayData={}))['#{info.to_json}']"
      "#{space}#{class_name} = #{xray} = #{func}"
    end
  end

  def self.augment_template(source, path)
    augmented_source = \
      "<script type='xray-template-start' data-xray-path='#{path}'></script>" +
      "\n#{source}\n" +
      "<script type='xray-template-end'></script>"
    ActionView::OutputBuffer === source ? ActionView::OutputBuffer.new(augmented_source) : augmented_source
  end

  class Engine < ::Rails::Engine
    paths['app/assets'] = 'lib/assets'

    config.after_initialize do
      # Augment JS files, including compiled coffeescript
      Rails.application.assets.register_postprocessor 'application/javascript', :xray do |context, data|
        if context.pathname.to_s =~ /\.(js|coffee)(\.|$)/
          Xray.augment_js(data, context.pathname.to_s)
        else
          data
        end
      end

      # Augment javascript templates
      Rails.application.assets.register_preprocessor 'application/javascript', :xray do |context, data|
        if context.pathname.to_s =~ /\.jst(\.|$)/
          Xray.augment_template(data, context.pathname.to_s)
        else
          data
        end
      end

      # Augment Rails partials
      ActionView::PartialRenderer.class_eval do
        def render_partial_with_xray
          source = render_partial_without_xray
          path = find_template.identifier
          Xray.augment_template(source, path)
        end
        alias_method_chain :render_partial, :xray
      end
    end
  end
end