class ApplicationController < ActionController::Base
  protect_from_forgery

  def root
  end

  # For the tests
  def non_html
    render json: {foo: 'bar'}
  end

  def made_with_haml
    respond_to :json
  end
end
