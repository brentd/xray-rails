require 'spec_helper'

describe 'Xray.open_file' do
  let(:file) { '/path/to/file' }

  it "uses the configured editor" do
    Xray.config.stub(editor: 'cool_editor')
    Open3.should_receive(:capture3).with("cool_editor \"#{file}\"")
    Xray.open_file(file)
  end

  it "replace $file in the editor command with the filename" do
    Xray.config.stub(editor: 'cool_editor --open "$file"')
    Open3.should_receive(:capture3).with("cool_editor --open \"#{file}\"")
    Xray.open_file(file)
  end
end
