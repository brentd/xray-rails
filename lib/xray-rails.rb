require "json"
require "active_support/all"
require_relative "xray/version"
require_relative "xray/aliasing"
require_relative "xray/config"
require_relative "xray/middleware"

if defined?(Rails) && Rails.env.development?
  require "xray/engine"
end

module Xray
  FILE_PLACEHOLDER = '$file'

  # Used to collect request information during each request cycle for use in
  # the Xray bar.
  def self.request_info
    Thread.current[:request_info] ||= {}
  end

  # Returns augmented HTML where the source is simply wrapped in an HTML
  # comment with filepath info. Xray.js uses these comments to associate
  # elements with the templates that rendered them.
  #
  # This:
  #   <div class=".my-element">
  #     ...
  #   </div>
  #
  # Becomes:
  #   <!-- XRAY START 123 /path/to/file.html -->
  #   <div class=".my-element">
  #     ...
  #   </div>
  #   <!-- XRAY END 123 -->
  def self.augment_template(source, path)
    id = next_id
    if source.include?('<!DOCTYPE')
      return source
    end
    # skim doesn't allow html comments, so use skim's comment syntax if it's skim
    if path =~ /\.(skim|hamlc)(\.|$)/
      augmented = "/!XRAY START #{id} #{path}\n#{source}\n/!XRAY END #{id}"
    else
      augmented = "<!--XRAY START #{id} #{path}-->\n#{source}\n<!--XRAY END #{id}-->"
    end
    ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
  end

  def self.next_id
    @id = (@id ||= 0) + 1
  end

  def self.open_file(file)
    editor = Xray.config.editor
    cmd = if editor.include?('$file')
      editor.gsub '$file', file
    else
      "#{editor} \"#{file}\""
    end
    Open3.capture3(cmd)
  end
end
