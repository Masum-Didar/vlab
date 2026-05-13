# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

[
  ["Beaker A", "beaker"],
  ["Beaker B", "beaker"],
  ["Test Tube 1", "test_tube"],
  ["Test Tube 2", "test_tube"],
  ["Conical Flask", "flask"],
  ["Measuring Cylinder", "measuring_cylinder"],
  ["Pipette", "pipette"]
].each do |name, container_type|
  container = Container.find_or_initialize_by(name: name)
  container.container_type = container_type
  container.save!
end

gel_equipment = [
  ["Chamber lid", "electrophoresis_lid"],
  ["DNA samples", "sample_tubes"],
  ["Electrophoresis buffer", "buffer_bottle"],
  ["Electrophoresis chamber", "electrophoresis_chamber"],
  ["Gel casting tray", "gel_tray"],
  ["Gel comb", "gel_comb"],
  ["Masking tape", "tape"],
  ["Micropipette", "micropipette"],
  ["Micropipette tips", "pipette_tips"],
  ["Power source", "power_supply"],
  ["UV-table", "uv_table"],
  ["Autoclave bag", "biohazard_bag"],
  ["Hot plate", "hot_plate"]
]

gel_equipment.each do |name, equipment_type|
  equipment = Equipment.find_or_initialize_by(name: name)
  equipment.equipment_type = equipment_type
  equipment.save!
end

gel_chemicals = [
  ["Hot liquid agarose", "agarose", "liquid", "#d9c48d", "Molten agarose used to cast the gel matrix."],
  ["Ethidium bromide", "EtBr", "aqueous", "#8b5a2b", "DNA stain used to visualize bands under UV illumination."],
  ["Electrophoresis buffer", "TAE/TBE", "aqueous", "#d7f2ff", "Conductive buffer that covers the gel during electrophoresis."],
  ["TNF1 control", "DNA", "aqueous", "#5846a3", "Reference DNA control loaded into well 1."],
  ["TNF2 control", "DNA", "aqueous", "#5846a3", "Reference DNA control loaded into well 2."],
  ["DNA Sample 1", "DNA", "aqueous", "#233f9d", "Unknown DNA sample loaded into well 3."],
  ["DNA Sample 2", "DNA", "aqueous", "#233f9d", "Unknown DNA sample loaded into well 4."],
  ["DNA Sample 3", "DNA", "aqueous", "#233f9d", "Unknown DNA sample loaded into well 5."]
]

gel_chemicals.each do |name, formula, state, color_hex, description|
  chemical = Chemical.find_or_initialize_by(name: name)
  chemical.assign_attributes(formula: formula, state: state, color_hex: color_hex, description: description, properties: {})
  chemical.save!
end

gel_containers = [
  ["Gel casting tray", "gel_tray"],
  ["Electrophoresis chamber", "electrophoresis_chamber"],
  ["DNA sample rack", "sample_rack"],
  ["Autoclave bag", "biohazard_bag"],
  ["UV-table", "uv_table"]
]

gel_containers.each do |name, container_type|
  container = Container.find_or_initialize_by(name: name)
  container.container_type = container_type
  container.save!
end

experiment = Experiment.find_or_initialize_by(title: "Gel Electrophoresis Lab")
experiment.assign_attributes(
  description: "Prepare an agarose gel, load DNA controls and samples, separate fragments, and interpret DNA bands under UV light.",
  duration: 120,
  difficulty: 2,
  published: true,
  status: :started,
  config: {
    source_files: {
      pdf: "/home/masum/Downloads/Gel Electro-lab.pdf",
      video: "/home/masum/Downloads/Gel Electro-Lab-Full.mp4"
    },
    lab_data_fields: ["TNF1", "TNF2", "DNA Sample 1", "DNA Sample 2", "DNA Sample 3", "Conclusion"],
    target_voltage: 70,
    run_minutes: 90
  }
)
experiment.save!

ExperimentEquipment.where(experiment: experiment).delete_all
gel_equipment.each do |name, _equipment_type|
  ExperimentEquipment.find_or_create_by!(experiment: experiment, equipment: Equipment.find_by!(name: name))
end

ExperimentChemical.where(experiment: experiment).delete_all
gel_chemicals.each do |name, _formula, _state, _color_hex, _description|
  ExperimentChemical.find_or_create_by!(experiment: experiment, chemical: Chemical.find_by!(name: name)) do |record|
    record.quantity_default = 1
  end
end

phase_definitions = [
  {
    title: "Lab orientation",
    description: "Identify the lab equipment used in the gel electrophoresis simulation.",
    steps: [
      "Identify the lab equipment you will use in this simulation by moving the labels to the correct item."
    ],
    action: :label_match
  },
  {
    title: "Prepare an agarose gel",
    description: "Cast the agarose gel, add DNA stain, and place the gel in the electrophoresis chamber.",
    steps: [
      "Assemble gel casting tray by mounting masking tape in both ends.",
      "Add gel comb to create wells for loading DNA samples.",
      "Add ethidium bromide to the hot liquid agarose.",
      "Carefully pour agarose solution into assembled gel casting tray to prevent formation of air bubbles.",
      "Allow gel to solidify for at least 10 minutes.",
      "Remove gel comb and masking tape.",
      "Place agarose gel casting tray in electrophoresis chamber.",
      "Fill chamber with electrophoresis buffer."
    ],
    action: :equipment_use
  },
  {
    title: "Load DNA samples",
    description: "Use a new micropipette tip for each DNA transfer and discard used tips in the autoclave bag.",
    steps: [
      "Place tip onto micropipette and transfer TNF1 into well 1 of tray. This control allows one to identify which sample is TNF1. Put used tip in Autoclave bag.",
      "Place new tip onto micropipette and transfer TNF2 into well 2 of tray. This control allows one to identify which sample is TNF2. Put used tip in Autoclave bag.",
      "Place new tip onto micropipette and transfer DNA Sample 1 into well 3 of the tray. Put used tip in Autoclave bag.",
      "Place new tip onto micropipette and transfer DNA Sample 2 into well 4 of the tray. Put used tip in Autoclave bag.",
      "Place new tip onto micropipette and transfer DNA Sample 3 into well 5 of the tray. Put used tip in Autoclave bag."
    ],
    action: :transfer
  },
  {
    title: "Separate DNA fragments",
    description: "Run the gel at 70 V for one hour and thirty minutes, then move the tray to the UV-table.",
    steps: [
      "Place lid on electrophoresis chamber.",
      "Turn power source on.",
      "Set voltage to 70 V by using the arrow keys on the power source.",
      "Click play on power source.",
      "Run the gel for one hour and thirty minutes until DNA bands have been sufficiently separated to allow identification.",
      "Click pause on power source.",
      "Turn power source off.",
      "Remove lid from electrophoresis chamber.",
      "Place gel casting tray onto UV-table."
    ],
    action: :equipment_use
  },
  {
    title: "Examine the results",
    description: "Use UV illumination to compare test sample bands with TNF1 and TNF2 controls.",
    steps: [
      "Turn on UV-light using power switch on UV-table.",
      "Identify genotypes in test samples by matching their DNA bands with DNA bands in TNF1 and TNF2 controls. Record your observations in Lab Data."
    ],
    action: :equipment_use
  },
  {
    title: "Conclusion",
    description: "Write the final conclusion from the observed DNA banding patterns.",
    steps: [
      "My Conclusion:"
    ],
    action: :equipment_use
  },
  {
    title: "Save Lab Data",
    description: "Review and save lab data for personal reference.",
    steps: [
      "Relevant Lab Data is available to be saved for personal reference. Data will be available if you return to this laboratory simulation."
    ],
    action: :equipment_use
  }
]

experiment.experiment_phases.destroy_all
phase_definitions.each_with_index do |phase_data, phase_index|
  phase = experiment.experiment_phases.create!(
    title: phase_data[:title],
    description: phase_data[:description],
    position: phase_index + 1
  )

  phase_data[:steps].each_with_index do |instruction, step_index|
    phase_step = phase.phase_steps.create!(
      instruction: instruction,
      step_number: step_index + 1,
      position: step_index + 1,
      completion_criteria: "Complete the action described for #{phase.title}.",
      timer_duration: instruction.include?("one hour and thirty minutes") ? 90.minutes.to_i : nil
    )

    action = phase_step.step_actions.create!(
      instruction: instruction,
      action_type: phase_data[:action],
      position: 1
    )

    if phase_data[:action] == :label_match && step_index.zero?
      gel_equipment.first(10).each_with_index do |(name, _equipment_type), label_index|
        action.step_action_labels.create!(
          label_text: name,
          correct_match: true,
          position: label_index + 1
        )
      end
    end
  end
end
