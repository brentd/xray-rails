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

    it 'should render and augment when template source is an empty string' do
      subject.should_receive(:render_without_xray).with(*xray_enabled_render_args).and_return('')
      subject.should_receive(:identifier).and_return(html_identifier)
      Xray.should_receive(:augment_template).with('', html_identifier).and_return(augmented_render_result)
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

    it 'should render but not augment when template source is nil' do
      subject.should_receive(:render_without_xray).with(*xray_enabled_render_args).and_return(nil)
      subject.should_receive(:identifier).and_return(html_identifier)
      Xray.should_not_receive(:augment_template)
      expect(subject.render(*xray_enabled_render_args)).to eql(nil)
    end
  end

  context 'ActionView::ViewPaths monkeypatch' do
    context 'on adding single variant path' do
      let(:view_path_arg) { Rails.root.join('app', 'views', 'variant_1') }

      context '#append_view_path' do
        subject { Xray.request_info[:view_paths][:append] }

        it 'should append additional view paths to Xray.request_info[:view_paths][:append]' do
          allow_any_instance_of(ActionView::LookupContext).to receive(:append_view_path_without_xray).with(view_path_arg)
          allow_any_instance_of(ActionView::LookupContext).to receive(:append_view_path).with(view_path_arg)
          ActionController::Base.new.append_view_path view_path_arg
          is_expected.to include(view_path_arg)
        end
      end
      context '#prepend_view_path' do
        subject { Xray.request_info[:view_paths][:prepend] }

        it 'should prepend additional view paths to Xray.request_info[:view_paths][:prepend]' do
          allow_any_instance_of(ActionView::LookupContext).to receive(:prepend_view_path_without_xray).with(view_path_arg)
          allow_any_instance_of(ActionView::LookupContext).to receive(:prepend_view_path).with(view_path_arg)
          ActionController::Base.new.prepend_view_path(view_path_arg)
          is_expected.to include(view_path_arg)
        end
      end
    end

    context 'on adding arrayed variant path' do
      let(:view_path_arg) { [Rails.root.join('app', 'views', 'variant_1'), Rails.root.join('app', 'views', 'variant_2')] }

      context '#append_view_path' do
        subject { Xray.request_info[:view_paths][:append] }

        it 'should append additional view paths to Xray.request_info[:view_paths][:append]' do
          allow_any_instance_of(ActionView::LookupContext).to receive(:append_view_path_with_xray).with(view_path_arg)
          allow_any_instance_of(ActionView::LookupContext).to receive(:append_view_path).with(view_path_arg)
          ActionController::Base.new.append_view_path view_path_arg
          is_expected.to include(*view_path_arg)
        end
      end
      context '#prepend_view_path' do
        subject { Xray.request_info[:view_paths][:prepend] }

        it 'should prepend additional view paths to Xray.request_info[:view_paths][:prepend]' do
          allow_any_instance_of(ActionView::LookupContext).to receive(:prepend_view_path_without_xray).with(view_path_arg)
          allow_any_instance_of(ActionView::LookupContext).to receive(:prepend_view_path).with(view_path_arg)
          ActionController::Base.new.prepend_view_path view_path_arg
          is_expected.to include(*view_path_arg)
        end
      end
    end
  end
end

