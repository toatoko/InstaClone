class UsersController < ApplicationController
  before_action :authenticate_user!, except: [ :show, :profile ]
  before_action :set_user, only: [ :show, :follow, :unfollow ]

  def index
    @user = current_user

    if current_user
      # Eager load the blocked user associations to avoid N+1 queries
      current_user_with_blocks = User.includes(:blocked_users, :blocked_by_users).find(current_user.id)

      # Use the associations instead of direct pluck queries
      blocked_user_ids = current_user_with_blocks.blocked_users.pluck(:id)
      blocked_by_user_ids = current_user_with_blocks.blocked_by_users.pluck(:id)
      excluded_user_ids = (blocked_user_ids + blocked_by_user_ids).uniq
    else
      excluded_user_ids = []
    end

    @posts = Post.joins(:user)
               .where(users: { banned_at: nil }) # Filter banned users
               .where.not(user_id: excluded_user_ids) # Filter blocked users
               .includes([ :image_attachment, user: [ :avatar_attachment ] ])
               .where(active: true)
               .order(created_at: :desc)
               .page(params[:page]).per(12)

    # Filter suggested users to exclude blocked users - with eager loading
    @suggested_users = User.active
                         .all_except(current_user)
                         .where.not(id: excluded_user_ids)
                         .includes(:avatar_attachment)
                         .limit(4)

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

    # Check if the user's content should be visible
    if current_user && @user != current_user && !@user.content_visible_to?(current_user)
      redirect_to root_path, alert: "This profile is not available."
      return
    end

    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)

    # Eager load current_user's blocked associations for the checks below
    if current_user.present?
      current_user_with_blocks = User.includes(:blocked_users, :blocked_by_users).find(current_user.id)
      @is_following = current_user != @user && current_user.following.exists?(id: @user.id)
      @is_blocked = current_user_with_blocks.blocked?(@user)
      @blocked_by = current_user_with_blocks.blocked_by?(@user)
    else
      @is_following = false
      @is_blocked = false
      @blocked_by = false
    end
  end

  def show
    # Check if the user's content should be visible
    if current_user && @user != current_user && !@user.content_visible_to?(current_user)
      redirect_to root_path, alert: "This profile is not available."
      return
    end

    @posts = @user.posts.includes(:image_attachment)
                  .where(active: true)
                  .order(created_at: :desc)

    # Eager load current_user's blocked associations for the checks below
    if current_user.present?
      current_user_with_blocks = User.includes(:blocked_users, :blocked_by_users).find(current_user.id)
      @is_following = current_user != @user && current_user.following.exists?(id: @user.id)
      @is_blocked = current_user_with_blocks.blocked?(@user)
      @blocked_by = current_user_with_blocks.blocked_by?(@user)
    else
      @is_following = false
      @is_blocked = false
      @blocked_by = false
    end

    render :profile
  end

  def all_users
    # Eager load blocked associations for the current user and all users
    @users = User.visible_to(current_user)
                 .includes(:avatar_attachment)
                 .all_except(current_user)

    # Preload current user's blocked associations if signed in
    if current_user
      User.includes(:blocked_users, :blocked_by_users).find(current_user.id)
    end
  end

  def follow
    # Eager load to avoid N+1 when checking mutually_blocked?
    current_user_with_blocks = User.includes(:blocked_users, :blocked_by_users).find(current_user.id)

    if current_user_with_blocks.mutually_blocked?(@user)
      redirect_back fallback_location: root_path, alert: "Cannot follow this user."
      return
    end

    current_user.follow(@user)
    respond_to do |format|
      format.turbo_stream do
        # Check if we're on the all_users page
        if request.referer&.include?("suggested_followers")
          render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}",
            partial: "users/follow_button_all_users",
            locals: { user: @user },
            formats: [ :html ])
        else
          render turbo_stream: turbo_stream.replace("user_#{@user.id}",
            partial: "users/suggested_user",
            locals: { user: @user },
            formats: [ :html ])
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
        if request.referer&.include?("suggested_followers")
          render turbo_stream: turbo_stream.replace("follow_button_#{@user.id}",
            partial: "users/follow_button_all_users",
            locals: { user: @user },
            formats: [ :html ])
        else
          render turbo_stream: turbo_stream.replace("user_#{@user.id}",
            partial: "users/suggested_user",
            locals: { user: @user },
            formats: [ :html ])
        end
      end
      format.html { redirect_back fallback_location: root_path }
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
