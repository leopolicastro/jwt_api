json.cache! [user] do
  json.extract! user, :id, :email, :first_name, :last_name
  json.content render(partial: 'users/user', locals: { user: user }, formats: [:html])
end
