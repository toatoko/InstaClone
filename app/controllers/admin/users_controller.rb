class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :destroy, :toggle_admin]

  def index
    @users = User.includes(:avatar_attachment).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def toggle_admin
    @user.update!(admin: !@user.admin?)
    redirect_to admin_users_path, notice: "User admin status updated."
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end

  def require_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end

  def user_params
    params.require(:user).permit(:username, :email, :admin)
  end
end