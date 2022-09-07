# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :accounts, only: %i(show create update) do
        resources :transactions, only: %i(index show create), on: :member
      end
    end
  end
end
