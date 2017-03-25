Rails.application.routes.draw do
  resources :podcasts do
    member do
      get 'export'
    end
  end

  root 'podcasts#index'
end