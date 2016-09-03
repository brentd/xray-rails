module Xray

  def self.config
    @@config ||= Config.new
  end

  class Config
    attr_accessor :editor

    CONFIG_FILE = ".xrayconfig"

    def default_editor
      ENV['GEM_EDITOR'] ||
        ENV['VISUAL'] ||
        ENV['EDITOR'] ||
        '/usr/local/bin/subl'
    end

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

    def config_file
      if File.exists?("#{Dir.pwd}/#{CONFIG_FILE}")
        "#{Dir.pwd}/#{CONFIG_FILE}"
      else
        "#{Dir.home}/#{CONFIG_FILE}"
      end
    end

    private

    def write_config(new_config)
      config = load_config.merge(new_config)
      File.open(config_file, 'w') { |f| f.write(config.to_yaml) }
    end

    def load_config
      default_config.merge(local_config)
    end

    def local_config
      YAML.load_file(config_file)
    rescue
      {}
    end

    def default_config
      { editor: default_editor }
    end
  end
end
