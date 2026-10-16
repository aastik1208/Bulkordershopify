Rails.application.routes.draw do
  mount ShopifyApp::Engine, at: '/'

  root 'home#index'

  resources :order_uploads, only: [:new, :create, :update] do
    collection do
      get 'download_sample_order_file'
    end
  end
  get '/order_uploads', to: redirect('order_uploads/new')

  resource :themes, only: [:edit, :update] do
    collection do
      get 'download_product_bulk_order_file'
      get 'theme_modification_removal_instructions'
      get 'edit_selected_products'
      post 'update_selected_products'
      get 'get_shopify_products_options'
    end
  end

  resources :shops, only: [] do
    member do
      put :update_contact_emails
      patch :update_contact_emails
    end
  end

  namespace :store_front do
    resources :order_uploads, only: :create do
      collection do
        get 'download_sample_order_file'
      end
    end
  end

  resources :countries, only: [:index] do
    post :search, on: :collection
  end
end
