require 'spec_helper'

describe "Xray Bar", type: :request do
  subject { find("#xray-bar") }

  context "includes an #xray-bar element" do
    before { visit '/' }

    it "with the controller and action" do
      is_expected.to have_text('ApplicationController#root')
    end

    it "with the layout used" do
      is_expected.to have_text('application.html.erb')
    end

    it "with the view rendered" do
      is_expected.to have_text('root.html.erb')
    end
  end

  context "with views in paths" do
    context "appended by #append_view_path_without_xray" do
      let(:path) { "/appended_view_path_without_xray" }

      it "should not resolve the layout location" do
        get path
        expect(response).to have_http_status(500)
      end
    end

    context "prepended by #prepend_view_path_without_xray" do
      let(:path) { "/prepended_view_path_without_xray" }

      it "should not resolve the layout location" do
        get path
        expect(response).to have_http_status(500)
      end
    end
  end

  context "with views in paths" do
    let(:layout) { "another.html.erb" }
    let(:view) { "additional_view.html.erb" }
    before { visit path }

    context "appended by #append_view_path" do
      let(:path) { "/appended_view_path" }

      it "should resolve the layout location" do
        is_expected.to have_text(layout)
        is_expected.to have_text(view)
      end
    end

    context "prepended by #prepend_view_path" do
      let(:path) { "/prepended_view_path" }

      it "should resolve the layout location" do
        is_expected.to have_text(layout)
        is_expected.to have_text(view)
      end
    end
  end
end
