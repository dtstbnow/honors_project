Rails.application.routes.draw do

  devise_for :users
  root  to: 'images#index', as: 'home'
  
  post '/', to: 'images#search', as: 'search'


  get 'tags/:id/:score', to: 'tags#rate', as: 'rate_tag'

  get 'users', to: 'users#index', as: 'users'

  get 'users/new', to: 'users#new', as: 'user'

  post 'users/new', to: 'users#create'

  get 'images', to: 'images#index', as: 'images'

  get 'images/:offset', to: 'images#index', as: 'images_page'

  get 'images/new', to: 'images#new', as: 'image'

  post 'images/new', to: 'images#create'

  get 'images/:id/edit', to: 'images#edit', as: 'edit_image'
  post '/images/:id/edit', to: 'images#update'

  get 'users/rec', to: 'rec#index', as: 'rec'
  get 'users/rec/history', to: 'rec#history', as: 'rec_history'

end
