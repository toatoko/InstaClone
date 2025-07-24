class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip

    @users = User.where(
      "username ILIKE :q OR first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
      q: "%#{@query}%"
    )

    @posts = Post.where("description ILIKE ?", "%#{@query}%").includes(:user)
  end
end
