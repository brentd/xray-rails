require 'spec_helper'

describe Xray::Engine do
  context 'ActionView::Template monkeypatch #render' do
    subject { ActionView::Template.new(nil, nil, nil, {}) }
    let(:xray_enabled_render_args) { ['template', { example_option: true }] }
    let(:xray_disabled_render_args) { ['template', { example_option: true, xray: false }] }
    let(:render_result) { '<html>Example</html>' }
    let(:plain_text_result) { 'Example' }
    let(:augmented_render_result) { '<html>Example<script>Example XRAY</script></html>' }
    let(:html_identifier) { 'template.html' }
    let(:txt_identifier) { 'template.txt' }

    it 'should render and augment valid HTML like files by default' do
      subject.should_receive(:render_without_xray).with(*xray_enabled_render_args).and_return(render_result)
      subject.should_receive(:identifier).and_return(html_identifier)
      Xray.should_receive(:augment_template).with(render_result, html_identifier).and_return(augmented_render_result)
      expect(subject.render(*xray_enabled_render_args)).to eql(augmented_render_result)
    end

    it 'should render but not augment HTML if :xray => false passed as an option' do
      subject.should_receive(:render_without_xray).with(*xray_enabled_render_args).and_return(render_result)
      subject.should_receive(:identifier).and_return(html_identifier)
      Xray.should_receive(:augment_template).with(render_result, html_identifier).and_return(augmented_render_result)
      expect(subject.render(*xray_enabled_render_args)).to eql(augmented_render_result)
    end

    it 'should render but not augment non HTML files' do
      subject.should_receive(:render_without_xray).with(*xray_disabled_render_args).and_return(plain_text_result)
      subject.should_receive(:identifier).and_return(txt_identifier)
      Xray.should_not_receive(:augment_template)
      expect(subject.render(*xray_disabled_render_args)).to eql(plain_text_result)
    end
  end
end

