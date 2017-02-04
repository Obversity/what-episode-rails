Rails.application.routes.draw do
  resources :shows
  get 'shows_list', to: 'shows#shows_list'
  resources :episodes do
    resources :questions do
      put 'flag', to: 'questions#flag'
    end
  end
end
