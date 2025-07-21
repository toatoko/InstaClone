class Admin::PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.includes(:user, :image_attachment).order(created_at: :desc).page(params[:page]) if defined?(Post)
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to admin_post_path(@post), notice: 'Post was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: 'Post was successfully deleted.'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def post_params
    params.require(:post).permit(:caption, :active)
  end
end
