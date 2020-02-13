Rails.application.routes.draw do
  root to: redirect('/admin/docs')

  namespace :admin do
    resources :docs, only: [:index, :show]
  end

  mount Larvata::Signing::Engine => "/larvata-signing"
end
