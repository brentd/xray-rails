require "json"
require "active_support/all"
require_relative "xray/version"
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

  # Patterns for the kind of JS constructors Xray is interested in knowing the
  # filepath of. Unforunately, these patterns will result in a lot of false
  # positives, because we can't only match direct Backbone.View subclasses -
  # the app's JS may have a more complex class hierarchy than that.
  CONSTRUCTOR_PATTERNS = [
    '(?!jQuery|_)[\w\.]+\.extend\({', # Match uses of extend(), excluding jQuery and underscore
    '\(function\(_super\) {'          # Coffeescript-generated constructors
  ]

  # Example matches:
  #   MyView = Backbone.View.extend({ ...
  #   Foo.MyView = Backbone.View.extend({ ...
  #   MyView = (function(_super) { ...
  #
  # Captures:
  #   $1 = space before the constructor
  #   $2 = the constructor's name
  #   $3 = the beginning of the constructor function
  CONSTRUCTOR_REGEX = /^( *)([\w\.]+) *= *(#{CONSTRUCTOR_PATTERNS.join('|')})/

  # Returns augmented JS source where constructors Xray wants to know the
  # filepath of are captured in such a way that at runtime, xray.js can look
  # up a view constructor's filepath and name.
  #
  # This:
  #   MyView = Backbone.View.extend({ ...
  #
  # Becomes:
  #   MyView = (window.XrayPaths||(window.XrayPaths={}))['{"name":"MyView","path":"/path/to/file.js"}'] = Backbone.View.extend({ ...
  #
  # A goal here was to not add any new lines to the source so as not to throw
  # off line numbers if an exception is thrown, hence the odd pattern of
  # abusing an object set operation in a multiple assignment.
  #
  # TODO: This is simple and gets the job done, but is a bit ridiculous.
  #       I've also seen this appear in stack traces :( Would love to find a
  #       way to do this without actually writing to the files.
  def self.augment_js(source, path)
    source.gsub(CONSTRUCTOR_REGEX) do
      space, class_name, func = $1, $2, $3
      info = {name: class_name, path: path.to_s}
      xray = "(window.XrayPaths||(window.XrayPaths={}))['#{info.to_json}']"
      "#{space}#{class_name} = #{xray} = #{func}"
    end
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
