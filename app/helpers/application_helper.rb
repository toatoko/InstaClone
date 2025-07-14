module ApplicationHelper
  def user_profile_link(user)
    user == current_user ? profile_path : user_profile_path(user.username)
  end
end
