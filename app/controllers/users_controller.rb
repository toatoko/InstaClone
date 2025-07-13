class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :profile ]

  def index
    @users = User.includes(:avatar_attachment)
    # user feed
    @posts = Post.includes([ :image_attachment, user: [ :avatar_attachment ] ]).where(active: true).order(created_at: :desc).page(params[:page]).per(10)
  end
  def profile
    # user profile
  end
  def set_user
    @user = User.find_by_username(params[:username])
  end

  private
end
