class ApplicationController < ActionController::Base
  protect_from_forgery

  def root
    render inline: 'lol', layout: true
  end
end
