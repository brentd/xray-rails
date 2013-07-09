require 'spec_helper'

describe Xray::Config do

  context ".config_file" do
    it "should use $HOME/.xrayconfig as default config file" do
      Dir.stub(:home).and_return('/home')
      Xray.config.config_file.should eq('/home/.xrayconfig')
    end

    it "should use $PROJECT/.xrayconfig if it exists" do
      File.stub(:exists?).and_return(true)
      Dir.stub(:pwd).and_return('/project')
      Xray.config.config_file.should eq("/project/.xrayconfig")
    end
  end
end
