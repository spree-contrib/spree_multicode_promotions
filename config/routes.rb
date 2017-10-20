Spree::Core::Engine.add_routes do
  namespace :admin, path: Spree.admin_path do
    resources :promotions do
      resources :promotion_codes, only: [:index]
    end
  end
end
