json.cache! [user] do
  json.extract! user, :id, :email
  json.content render(partial: 'users/user', locals: { user: user }, formats: [:html])
end
