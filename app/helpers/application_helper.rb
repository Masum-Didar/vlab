module ApplicationHelper

  def status_badge_class(status)
    case status.to_s
    when 'pending' then 'bg-yellow-100 text-yellow-800 border-yellow-200'
    when 'graded', 'completed' then 'bg-emerald-100 text-emerald-800 border-emerald-200'
    when 'failed', 'rejected' then 'bg-red-100 text-red-800 border-red-200'
    else 'bg-gray-100 text-gray-800 border-gray-200'
    end
  end
end
