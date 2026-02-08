module ApplicationHelper

  def status_badge_class(status)
    case status.to_s
    when 'pending' then 'badge bg-warning text-dark'
    when 'graded', 'completed' then 'badge bg-success'
    when 'failed', 'rejected' then 'badge bg-danger'
    else 'badge bg-secondary'
    end
  end
end
