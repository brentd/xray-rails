module Xray

  def self.config
    @@config ||= Config.new
  end

  class Config
    attr_accessor :editor

    CONFIG_FILE = "#{Dir.home}/.xrayconfig"
    DEFAULT_EDITOR = '/usr/local/bin/subl'

    def editor
      load_config[:editor]
    end

    def editor=(new_editor)
      if new_editor && new_editor != editor
        write_config(editor: new_editor)
        true
      else
        false
      end
    end

    def to_yaml
      {editor: editor}.to_yaml
    end

    private

    def write_config(new_config)
      config = load_config.merge(new_config)
      File.open(CONFIG_FILE, 'w') { |f| f.write(config.to_yaml) }
    end

    def load_config
      default_config.merge(local_config)
    end

    def local_config
      YAML.load_file(CONFIG_FILE)
    rescue
      {}
    end

    def default_config
      { editor: DEFAULT_EDITOR }
    end

  end
end
