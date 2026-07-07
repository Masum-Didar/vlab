module StepActionsHelper

  def render_action_details(action)

    case action.action_type

    when "label_match"
      render "admin/step_actions/label_match", action: action

    when "equipment_use"
      render "admin/step_actions/equipment_use", action: action

    when "transfer"
      render "admin/step_actions/transfer", action: action

    when "voltage_set"
      target = action.config&.dig("target_voltage") || 70
      content_tag(:span, "Set to #{target}V (arrow keys)", class: "text-muted small")

    else
      content_tag(:span, "No details", class: "text-muted small")

    end

  end

end