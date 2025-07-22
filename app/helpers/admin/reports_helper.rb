module Admin::ReportsHelper
  def resolve_all_reports_path_for(reportable)
    case reportable
    when Post
      resolve_all_reports_admin_post_path(reportable)
    when Comment
      resolve_all_reports_admin_comment_path(reportable)
    when User
      resolve_all_reports_admin_user_path(reportable)
    else
      admin_reports_path
    end
  end
end
