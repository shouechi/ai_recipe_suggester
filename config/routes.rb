Rails.application.routes.draw do
  # Defines the root path route ("/")
  root "recipes#new"

  # Defines a route for creating a new recipe suggestion
  post "recipes", to: "recipes#create"
end
