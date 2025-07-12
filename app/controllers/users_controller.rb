class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.includes(:avatar_attachment)
    # user feed
    @posts = Post.includes([ :image_attachment, user: [ :avatar_attachment ] ]).where(active: true).order(created_at: :desc).page(params[:page]).per(10)
  end
  def show
    # user profile
  end

  private
end
