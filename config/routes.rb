Rails.application.routes.draw do
  
  resources :user_relationships
  post '/users', to: 'users#create'
  put '/users/:id', to: 'users#update'
  delete '/users/:id', to: 'users#destroy'
  get 'users/current-user', to: 'users#authenticated_user'
  
  post '/login', to: 'sessions#login'

  get '/bookshelves/search', to: 'bookshelves#search'
  get '/bookshelves/popular', to: 'bookshelves#popular'
  get '/bookshelves/:id', to: 'bookshelves#show'

  post '/bookshelves/:shelf_id/books/:isbn', to: 'stored_books#create'
  delete '/bookshelves/:shelf_id/books/:isbn', to: 'stored_books#destroy'

  post '/books', to: 'books#create'  
  put '/books/:isbn/approve', to: 'books#approve'
  delete '/books/:isbn/reject', to: 'books#reject'
  get '/books/popular', to: 'books#popular'
  get '/books/search', to: 'books#search'
  get '/books/:isbn/users/:user_id', to: 'books#book_of_someone'
  get '/books/:isbn', to: 'books#book_of_library'

  post '/reviews', to: 'reviews#create'
  put '/reviews/:id', to: 'reviews#update'
  delete '/reviews/:id', to: 'reviews#destroy'
  get 'reviews/:isbn', to: 'reviews#reviews_of_book'

  # resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
