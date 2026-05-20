module ExperimentsHelper
  def student_action_hint(action)
    config = action.config || {}

    case action.action_type
    when "label_match"
      "Match labels to the correct equipment."
    when "label_connect"
      label = config["label_name"].presence || "the label"
      equipment = Equipment.find_by(id: config["equipment_id"])&.name || "the correct equipment"
      "Connect #{label} with #{equipment}."
    when "equipment_connect"
      source = Equipment.find_by(id: config["source_equipment_id"])&.name || "source equipment"
      target = Equipment.find_by(id: config["target_equipment_id"])&.name || "target equipment"
      "Connect #{source} to #{target}."
    when "transfer"
      chemical = Chemical.find_by(id: config["chemical_id"])&.name || "the chemical"
      source = Container.find_by(id: config["source_container_id"])&.name || "source"
      target = Container.find_by(id: config["target_container_id"])&.name || "target"
      "Transfer #{chemical} from #{source} to #{target}."
    when "equipment_use"
      equipment = Equipment.find_by(id: config["equipment_id"])&.name || "the required equipment"
      "Use #{equipment}."
    when "quiz_input"
      config["question"].presence || "Answer the question."
    else
      config["prompt"].presence || action.instruction
    end
  end
end
