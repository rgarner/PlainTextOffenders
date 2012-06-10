Plaintextoffenders::Application.routes.draw do

  match 'about-us' => "pages#about_us", :as => 'about_us'
  match 'talk-to-us' => "pages#talk_to_us", :as => 'talk_to_us'
  match 'contact-us' => "pages#talk_to_us"
  match 'feed' => "offending_sites#feed", :format => 'atom', :as =>'feed'
  match 'rss' => "offending_sites#feed", :format => 'atom', :as =>'feed' # for backwards compatibility
  match 'search' => "offending_sites#search", :as =>'search'
  match 'terms' => "offending_sites#terms", :as =>'terms'
  match "check_site_url", :controller => "offending_sites", :action => "check_url"
  match 'create-new' => "offending_sites#new", :as => 'create_new'
  match 'site/:url' => "offending_sites#show_by_url", :constraints => { :url => /.*/ }, :as => 'show_by_url'

  resources :offending_sites, :only => [:index, :show, :new, :create, :feed, :search, :terms]

  namespace :admin do
    resources :offending_sites do
      member do
        get 'publish'
        get 'unpublish'
      end
    end
  end

  root :to => "offending_sites#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
