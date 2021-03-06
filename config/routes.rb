Rails.application.routes.draw do

  resources :cooperators do
    member {
      get :edit_phishing_data
      patch :edit_phishing_data, :action => :update_phishing_data
    }
  end

  post '/allow_cookies' => 'cookie_policy#allow'
  post '/deny_cookies'  => 'cookie_policy#deny'

  resources :events
  resources :images,                    constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}
  resources :orders,                    constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'} do
    collection {
      post :import_payments_csv
      post :remind_open_orders
    }
    member {
      post :purchase
      post :repay
    }
  end
  resources :products,                  constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}
  get 'sold_overview', :controller => :products, :action => :sold_overview,                  constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}
  resources :validation, :only => [:index], :path=>"/v", constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}
  get    'v/:sold_product_id/:verification_token', :controller => :validation, :action => :show,  constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}, as: :validation
  delete 'v/:sold_product_id/:verification_token', :controller => :validation, :action => :issue,  constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}, as: :issue
  resources :sold_products,              constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}

  devise_for :users

  get '/' => 'welcome#show',   constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www'}
  root :to => "welcome#index"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
