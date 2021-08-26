require 'rails/generators/base'

module JwtApi
  class SetupGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def source_paths
      [__dir__]
    end

    def add_api_namespace_to_routes
      routes = 'config/routes.rb'

      inject_into_file routes, after: 'Rails.application.routes.draw do' do
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
    post 'users/update_password' => 'passwords#update_password'
  end
end\n\n"
      end
    end

    def copy_api_routes
      directory 'templates/api', 'app/controllers/api'
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

    def generate_jti_migration
      migration_template 'migrations/jti_migration.rb', 'db/migrate/create_jti.rb'
    end

    # def copy_initializer
    #   template 'jwt_api.rb', 'config/initializers/jwt_api.rb'
    # end

    # def copy_routes
    #   template 'jwt_api_routes.rb', 'config/routes.rb'
    # end

    # def copy_controllers
    #   template 'jwt_api_controller.rb', 'app/controllers/jwt_api_controller.rb'
    # end

    # def copy_spec
    #   template 'jwt_api_spec.rb', 'spec/models/jwt_api_model_spec.rb'
    # end

    # def copy_test
    #   template 'jwt_api_test.rb', 'test/models/jwt_api_model_test.rb'
    # end
  end
end
