Rails.application.routes.draw do
  mount Larvata::Signing::Engine => "/larvata-signing"
end
