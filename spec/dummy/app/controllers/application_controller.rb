class ApplicationController < ActionController::Base
  protect_from_forgery

  if respond_to?(:content_security_policy) # Rails >= 5.2
    content_security_policy only: :strict_csp do |policy|
      policy.script_src :self, :strict_dynamic
    end
  end

  def root
  end

  def strict_csp
    render :root
  end

  # For the tests
  def non_html
    render json: {foo: 'bar'}
  end

  def made_with_haml
    respond_to :json
  end
end
