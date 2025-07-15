class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_user, only: [ :show, :follow, :unfollow ]

  def index
    @user = User.includes(:avatar_attachment)
    @posts = Post.includes([ :image_attachment, user: [ :avatar_attachment ] ])
                 .where(active: true)
                 .order(created_at: :desc)
                 .page(params[:page]).per(12)
    respond_to do |format|
      format.html
      format.json { render json: { posts: render_posts_json(@posts), has_more: @posts.next_page.present? } }
    end
  end

  def profile
    if params[:username].present? && params[:username] != current_user.username
      # If username is provided and it's not the current user, find that user
      @user = User.find_by(username: params[:username])
      redirect_to root_path, alert: "User not found" unless @user
    else
      # If no username or it's the current user's username, show current user's profile
      @user = current_user
    end

    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
    @is_following = current_user.present? && current_user != @user && current_user.following.exists?(id: @user.id)
  end

  def show
    # Use includes instead of joins to properly load attachments
    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
    @is_following = current_user.present? && current_user != @user && current_user.following.exists?(id: @user.id)
    render :profile
  end

  def follow
    current_user.follow(@user)
    redirect_back(fallback_location: user_profile_path(@user.username))
  end

  def unfollow
    current_user.unfollow(@user)
    redirect_back(fallback_location: user_profile_path(@user.username))
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])
    redirect_to root_path, alert: "User not found" unless @user
  end

  def user_params
    params.require(:user).permit(:name, :username, :bio, :email, :avatar)
  end

  def render_posts_json(posts)
    posts.map do |post|
      {
        id: post.id,
        images: post.image.attached? ? [ { url: Rails.application.routes.url_helpers.rails_blob_url(post.image, only_path: true), alt: "Post image" } ] : [],
        likes_count: post.likes.count,
        comments_count: post.comments.count,
        created_at: post.created_at,
        url: post_path(post)
      }
    end
  end
end
