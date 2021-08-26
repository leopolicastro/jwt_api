class JwtMailer < ApplicationMailer
  def reset_password(user_id, raw_token)
    @resource = User.find(user_id)
    # TODO: add url environement variable
    @token_link = "http://localhost:3000/users/password/edit?token=#{raw_token}"
    @token = raw_token
    mail(to: @resource.email, subject: 'Reset password instructions',
         template_name: 'reset_password')
  end
end
