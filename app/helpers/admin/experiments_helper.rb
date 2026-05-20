module Admin::ExperimentsHelper
  def experiment_readiness_items(experiment)
    phases = experiment.experiment_phases
    steps_count = phases.sum { |phase| phase.phase_steps.size }

    [
      ["Details", experiment.title.present? && experiment.description.present? && experiment.method_description.present?],
      ["Interactions", phases.any? { |phase| phase.phase_steps.any? { |step| step.step_actions.any? } }],
      ["Flow", phases.any? && steps_count.positive?],
      ["Settings", experiment.duration.to_i.positive? && experiment.difficulty.present?]
    ]
  end

  def experiment_ready_percentage(experiment)
    items = experiment_readiness_items(experiment)
    ((items.count { |_label, ready| ready }.to_f / items.size) * 100).round
  end

  def experiment_status_badge_class(experiment)
    return "text-bg-success" if experiment.published?

    case experiment.status
    when "started" then "text-bg-primary"
    when "completed" then "text-bg-success"
    when "failed" then "text-bg-danger"
    else "text-bg-secondary"
    end
  end

  def step_action_summary(action)
    config = action.config || {}

    case action.action_type
    when "label_match"
      config["label_pairs"].presence || "Label pairs not configured"
    when "label_connect"
      label = config["label_name"].presence || "label"
      equipment = Equipment.find_by(id: config["equipment_id"])&.name || "equipment not selected"
      "#{label} -> #{equipment}"
    when "equipment_connect"
      source = Equipment.find_by(id: config["source_equipment_id"])&.name || "source equipment"
      target = Equipment.find_by(id: config["target_equipment_id"])&.name || "target equipment"
      "#{source} -> #{target}"
    when "transfer"
      chemical = Chemical.find_by(id: config["chemical_id"])&.name || "chemical"
      source = Container.find_by(id: config["source_container_id"])&.name || "source"
      target = Container.find_by(id: config["target_container_id"])&.name || "target"
      quantity = config["quantity"].presence
      [chemical, quantity, "from #{source} to #{target}"].compact.join(" ")
    when "equipment_use"
      Equipment.find_by(id: config["equipment_id"])&.name || "Equipment not selected"
    when "quiz_input"
      config["question"].presence || "Question not configured"
    else
      config["prompt"].presence || "Instruction only"
    end
  end
end
