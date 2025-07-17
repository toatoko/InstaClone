class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :profile ]
  before_action :set_user, only: [ :show, :follow, :unfollow ]

  def index
    @user = User.includes(:avatar_attachment)
    @posts = Post.includes([ :image_attachment, user: [ :avatar_attachment ] ])
                 .where(active: true)
                 .order(created_at: :desc)
                 .page(params[:page]).per(12)
    @suggested_users = User.all_except(current_user).includes(:avatar_attachment).limit(4)
    respond_to do |format|
      format.html
      format.json { render json: { posts: render_posts_json(@posts), has_more: @posts.next_page.present? } }
    end
  end

  def profile
    if params[:username].present?
      # If username is provided, find that user
      @user = User.find_by(username: params[:username])
      unless @user
        redirect_to root_path, alert: "User not found"
        return
      end
    else
      # If no username, show current user's profile
      @user = current_user
    end

    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
    @is_following = current_user.present? && current_user != @user && current_user.following.exists?(id: @user.id)
  end

  def show
    # This method uses set_user callback, so @user is already set
    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)
    @is_following = current_user.present? && current_user != @user && current_user.following.exists?(id: @user.id)
    render :profile
  end

  def all_users
    @users = User.includes(:avatar_attachment).all_except(current_user)
  end

  def follow
    current_user.follow(@user)
    respond_to do |format|
      format.turbo_stream do
        # Check if we're on the all_users page
        if request.referer&.include?('suggested_followers')
          render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}",
            partial: "users/follow_button_all_users",
            locals: { user: @user },
            formats: [:html])
        else
          render turbo_stream: turbo_stream.replace("user_#{@user.id}", 
            partial: "users/suggested_user", 
            locals: { user: @user },
            formats: [:html])
        end
      end
      format.html { redirect_back fallback_location: profile_path(@user.username) }
    end
  end

  def unfollow
    current_user.unfollow(@user)
    respond_to do |format|
      format.turbo_stream do
        # Check if we're on the all_users page
        if request.referer&.include?('suggested_followers')
          render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}",
            partial: "users/follow_button_all_users",
            locals: { user: @user },
            formats: [:html])
        else
          render turbo_stream: turbo_stream.replace("user_#{@user.id}", 
            partial: "users/suggested_user", 
            locals: { user: @user },
            formats: [:html])
        end
      end
      format.html { redirect_back fallback_location: profile_path(@user.username) }
    end
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])
    unless @user
      redirect_to root_path, alert: "User not found"
    end
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