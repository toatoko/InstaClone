class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def dashboard
    @users_count = User.count
    @posts_count = Post.count
    @comments_count = Comment.count if defined?(Comment)
    @recent_users = User.includes(:avatar_attachment).order(created_at: :desc).limit(5)
    @recent_posts = Post.includes(:user, :image_attachment).order(created_at: :desc).limit(5) if defined?(Post)
  end

  def posts
    @posts = Post.includes(:user).order(created_at: :desc).page(params[:page]) if defined?(Post)
  end

  def comments
    @comments = Comment.includes(:user, :post).order(created_at: :desc).page(params[:page]) if defined?(Comment)
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied. You are not the admin" unless current_user&.admin?
  end
end
