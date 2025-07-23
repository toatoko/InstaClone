module ApplicationHelper
  def ban_button_for(user)
    return unless current_user&.admin? || can?(:ban, user)

    if user.banned?
      button_to "Unban", admin_user_ban_path(user.username),
                method: :delete,
                class: "btn btn-success btn-sm",
                confirm: "Are you sure you want to unban this user?"
    else
      button_to "Ban", admin_user_ban_path(user.username),
                method: :post,
                params: { user_ban: { reason: "Banned by admin" } },
                class: "btn btn-danger btn-sm",
                confirm: "Are you sure you want to ban this user?"
    end
  end

  def user_status_badge(user)
    if user.banned?
      content_tag :span, "Banned", class: "badge badge-danger"
    else
      content_tag :span, "Active", class: "badge badge-success"
    end
  end
end
