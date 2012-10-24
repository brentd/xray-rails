require "x-ray/version"
require 'sprockets'

# Hook into Sprockets
if defined?(Sprockets::ProcessedAsset)

  Sprockets::ProcessedAsset.class_eval do
    def source_with_xray
      source = source_without_xray
      Xray.augment_js(source, pathname)
    end
    alias_method_chain :source, :xray
  end

elsif defined?(Sprockets::BundledAsset) # older Rails

  Sprockets::BundledAsset.class_eval do
    def build_dependency_context_and_body_with_xray
      context, source = build_dependency_context_and_body_without_xray
      Xray.augment_js(source, pathname)
    end
    alias_method_chain :build_dependency_context_and_body, :xray
  end

end

# Hook into Rails partials
ActionView::PartialRenderer.class_eval do
  def render_partial_with_xray
    source = render_partial_without_xray
    path = find_template.identifier
    Xray.augment_template(source, path)
  end
  alias_method_chain :render_partial, :xray
end

module Xray
  CONSTRUCTOR_REGEX = /^([\s]*)(?!_)([\w\.]+)\s*\=\s*(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

  def self.augment_js(source, path)
    if path.to_s =~ /\.(js|coffee)/
      source.gsub(CONSTRUCTOR_REGEX) do
        space, class_name, func = $1, $2, $3
        info = {name: class_name, path: path.to_s}
        xray = "(window.XrayData||(window.XrayData={}))['#{info.to_json}']"
        "#{space}#{class_name} = #{xray} = #{func}"
      end
    else
      source
    end
  end

  def self.augment_template(source, path)
    if path.to_s =~ /\.(html|haml)/
      augmented_source = ActionView::OutputBuffer.new(
        "<script class='xray-template-start' data-xray-path='#{path}'></script>" +
        "\n#{source}\n" +
        "<script class='xray-template-end'></script>"
      )
    else
      source
    end
  end

  class Engine < ::Rails::Engine
    paths['app/assets'] = 'lib/assets'
  end
end