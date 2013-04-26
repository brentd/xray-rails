module Xray

  def self.config
    @@config ||= Config.new
  end

  class Config
    attr_accessor :editor

    CONFIG_FILE = "#{Dir.home}/.xrayconfig"
    DEFAULT_EDITOR = '/usr/local/bin/subl'

    def initialize
      load_config if File.exists?(CONFIG_FILE)
    end

    def editor
      @editor ||= '/usr/local/bin/subl'
    end

    def editor=(new_editor)
      if new_editor != editor && File.exists?(new_editor)
        @editor = new_editor
        write_config
      end
    end

    def to_yaml
      {editor: editor}.to_yaml
    end

    private

    def write_config
      File.open(CONFIG_FILE, 'w') { |f| f.write(to_yaml) }
    end

    def load_config
      saved_config = YAML.load_file(CONFIG_FILE)
      self.editor = saved_config[:editor]
    end

  end
end
