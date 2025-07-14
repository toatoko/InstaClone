class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]
  before_action :set_user, only: [ :show, :follow, :unfollow ]
  before_action :set_current_user, only: [ :profile ]

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
    # Use includes instead of joins to properly load attachments
    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
  end

  def show
    # Use includes instead of joins to properly load attachments
    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
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

  def set_current_user
    @user = current_user
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
