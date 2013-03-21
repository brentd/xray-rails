require "xray/version"
require "xray/middleware"

if defined?(Rails) && Rails.env.development?
  require "xray/engine"
end

module Xray
  def self.request_info
    @request_info ||= {}
  end

  # The kinds of constructors Xray is interested in knowing the filepath of.
  CONSTRUCTOR_PATTERNS = [
    'Backbone.View.extend\({',                      # Vanilla JS Backbone view
    '\(function\(_super\) {.*}\)\(Backbone\.View\)' # Coffeescript-generated constructor
  ]

  # Example matches:
  #   MyView = Backbone.View.extend({ ...
  #   Foo.MyView = Backbone.View.extend({ ...
  #   MyView = (function(_super) { ...
  #
  # Captures:
  #   $1 = space before the constructor
  #   $2 = the constructor's name
  #   $3 = the beginning of the function
  CONSTRUCTOR_REGEX = /^( *)([\w\.]+) *= *(#{CONSTRUCTOR_PATTERNS.join('|')})/m

  # Returns augmented JS source where constructors Xray wants to know the
  # filepath of are captured in such a way that at runtime, xray.js can look
  # up a view constructor's filepath and name.
  #
  # This:
  #   MyView = Backbone.View.extend({ ...
  #
  # Becomes:
  #   MyView = (window.XrayPaths||(window.XrayPaths={}))['{"name":"MyView","path":"path/to/file.js"}'] = MyView = Backbone.View.extend({ ...
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

  # Returns augmented HTML where it's simply wrapped in an HTML comment with filepath info.
  # Xray.js strips these comments from the DOM and save the filepath info in memory.
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
    @id = (@id ||= 0) + 1
    augmented = "<!-- XRAY START #{@id} #{path} -->\n#{source}\n<!-- XRAY END #{@id} -->"
    ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
  end
end
