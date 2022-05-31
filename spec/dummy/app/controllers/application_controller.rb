class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'another', only: %i(appended_view_path appended_view_path_without_xray prepended_view_path prepended_view_path_without_xray)

  def root
  end

  # For the tests
  def non_html
    render json: {foo: 'bar'}
  end

  def made_with_haml
    respond_to :json
  end

  def appended_view_path
    append_view_path [Rails.root.join('app', 'views', 'variant_1'), Rails.root.join('app', 'views', 'variant_2')]
    render :additional_view
  end
  def prepended_view_path
    prepend_view_path [Rails.root.join('app', 'views', 'variant_1'), Rails.root.join('app', 'views', 'variant_2')]
    render :additional_view
  end
  def appended_view_path_without_xray
    append_view_path_without_xray [Rails.root.join('app', 'views', 'variant_1'), Rails.root.join('app', 'views', 'variant_2')]
    render :additional_view
  end
  def prepended_view_path_without_xray
    prepend_view_path_without_xray [Rails.root.join('app', 'views', 'variant_1'), Rails.root.join('app', 'views', 'variant_2')]
    render :additional_view
  end
end
