Dummy::Application.routes.draw do
  root to: 'application#root'
  get '/:action', to: 'application'
end
