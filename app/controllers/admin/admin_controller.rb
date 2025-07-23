class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def dashboard
    @users_count = User.count

    @recent_users = User.includes(:avatar_attachment).order(created_at: :desc).limit(5)

    # ADDED THIS LINE: Fetch recent reports
    @recent_reports = Report.includes(:reporter).order(created_at: :desc).limit(5) if defined?(Report) # Ensure Report model exists
  end

  private

  def require_admin
    redirect_to root_path, alert: "Access denied. You are not the admin" unless current_user&.admin?
  end
end
