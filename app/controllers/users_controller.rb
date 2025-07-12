class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # user feed
    @posts = Post.includes(:user).where(active: true).order(created_at: :desc).page(params[:page]).per(10)
    @preloaded_urls = preload_urls_for_posts(@posts)
  end
  def show
    # user profile
  end




  private
  def preload_urls_for_posts(posts)
    {
      # Preload avatar URLs
      avatars: posts.map(&:user).uniq.each_with_object({}) do |user, hash|
        hash[user.id] = user.avatar.present? ? user.avatar.url : nil
      end,
      # Preload post image URLs
      post_images: posts.each_with_object({}) do |post, hash|
        hash[post.id] = post.image.url
      end
    }
  end
end
