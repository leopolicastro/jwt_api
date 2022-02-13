# JwtApi

Generate user, session, and password api routes with JWT authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jwt_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jwt_api

Generate your API:

    $ rails g jwt_api:setup

```
Running via Spring preloader in process 56238
      create  app/controllers/api
      create  app/controllers/api/base_controller.rb
      create  app/controllers/api/v1/authentication_controller.rb
      create  app/controllers/api/v1/passwords_controller.rb
      create  app/controllers/api/v1/users_controller.rb
      insert  config/routes.rb
      create  app/views/users
      create  app/views/users/_user.html.erb
      create  app/views/users/_user.json.jbuilder
      create  app/mailers/jwt_mailer.rb
      create  app/views/jwt_mailer
      create  app/views/jwt_mailer/reset_password.html.erb
      create  config/initializers/json_web_token.rb
    generate  migration
       rails  generate migration add_jti_to_users jti:string:uniq:index
Running via Spring preloader in process 56250
      invoke  active_record
      create    db/migrate/20210827123255_add_jti_to_users.rb
        rake  db:migrate
== 20210827123255 AddJtiToUsers: migrating ====================================
-- add_column(:users, :jti, :string)
   -> 0.0061s
-- add_index(:users, :jti, {:unique=>true})
   -> 0.0196s
== 20210827123255 AddJtiToUsers: migrated (0.0259s) ===========================
```


## Usage

1. Make sure that each user that needs access to the API has a JTI generated.
   1. `User.first.jti = SecureRandom.uuid`
2. Request a JWT at the `/api/authenticate/` endpoint.
3. Include that token as a `Bearer` token in all other requests.


[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/6130650-059cc2e3-88f7-48a8-95d0-d7dca1d7caef?action=collection%2Ffork&collection-url=entityId%3D6130650-059cc2e3-88f7-48a8-95d0-d7dca1d7caef%26entityType%3Dcollection%26workspaceId%3D128e0ba1-898b-40bb-8006-a329fb1c28de)


[Docs](https://documenter.getpostman.com/view/6130650/TzzHjXVv)

## Limitations
- Currently this will only work with a devise User model.
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/leopolicastro/jwt_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/jwt_api/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the JwtApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jwt_api/blob/main/CODE_OF_CONDUCT.md).


## TODO
- Create test suite and add to generator to copy into users app.