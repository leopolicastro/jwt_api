require 'rails/generators/base'

module JwtApi
  class SetupGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def source_paths
      [__dir__]
    end

    def copy_api_controllers
      directory 'templates/api', 'app/controllers/api'
    end

    def add_api_namespace_to_routes
      routes = 'config/routes.rb'
      inject_into_file routes, after: 'Rails.application.routes.draw do' do
        # TODO: this is ugly, there has to be a better way to do this
        "\n\n# API routes
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    # Auth
    post 'auth' => 'authentication#authenticate_user'
    delete 'auth' => 'authentication#logout'
    # Users
    resource :users
    get 'me' => 'users#me'
    # User Password Reset Flow
    post 'users/reset_password' => 'passwords#reset_password_instructions'
    get 'passwords/verify' => 'passwords#verify'
    post 'users/update_password' => 'passwords#update_password'
  end
end\n\n"
      end
    end

    def copy_user_views
      directory 'templates/views/users', 'app/views/users'
    end

    def copy_password_reset_mailer
      copy_file 'templates/mailers/jwt_mailer.rb', 'app/mailers/jwt_mailer.rb'
    end

    def copy_password_reset_views
      directory 'templates/views/jwt_mailer', 'app/views/jwt_mailer'
    end

    def copy_jwt_class
      copy_file 'templates/initializers/json_web_token.rb', 'config/initializers/json_web_token.rb'
    end

    def generate_jti_migration
      generate 'migration', 'add_jti_to_users', 'jti:string:uniq:index'
    end

    def run_migration
      rake 'db:migrate'
    end
  end
end
