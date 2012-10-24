require "x-ray/version"

require 'sprockets'

CONSTRUCTOR_REGEX = /^([\s]*)(?!_)([\w\.]+)\s*\=\s*(\(function\(_super\)|(?!jQuery|_)[\w\.]+.extend\()/

if defined?(Sprockets::ProcessedAsset)

  Sprockets::ProcessedAsset.class_eval do
    def source_with_xray
      source_without_xray.tap do |source|
        Xray.apply_to_js!(source, pathname)
      end
    end
    alias_method_chain :source, :xray
  end

elsif defined?(Sprockets::BundledAsset)

  Sprockets::BundledAsset.class_eval do
    def build_dependency_context_and_body_with_xray
      build_dependency_context_and_body_without_xray.tap do |(context, source)|
        Xray.apply_to_js!(source, pathname)
      end
    end
    alias_method_chain :build_dependency_context_and_body, :xray
  end

end

module Xray
  def self.apply_to_js!(source, pathname)
    if pathname.to_s =~ /\.(js|coffee)(\..+)?/
      source.gsub!(CONSTRUCTOR_REGEX) do
        space, class_name, func = $1, $2, $3
        puts "  --- INSERTING FOR: #{class_name}"
        info = {name: class_name, path: pathname.to_s}
        xray = "(window.XrayData||(window.XrayData={}))['#{info.to_json}']"
        "#{space}#{class_name} = #{xray} = #{func}"
      end
    end
  end

  class Engine < ::Rails::Engine
    paths['app/assets'] = 'lib/assets'
  end
end