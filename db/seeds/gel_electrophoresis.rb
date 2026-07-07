puts "Seeding Gel Electrophoresis experiment..."

ActsAsTenant.without_tenant do
  # --- Equipment ---
  equip = {}
  [
    ["Casting Tray", "tray"],
    ["Gel Comb", "comb"],
    ["Electrophoresis Chamber", "chamber"],
    ["Power Supply", "power_supply"],
    ["Micropipette (P20)", "pipette"],
    ["UV Transilluminator", "uv_table"],
    ["Agarose Container", "container"],
    ["Microcentrifuge Tubes", "tube_rack"]
  ].each do |name, etype|
    equip[name] = Equipment.find_or_create_by!(name: name) { |e| e.equipment_type = etype }
  end

  # --- Chemicals ---
  chem = {}
  chemicals = {
    "Agarose Powder" => "solid",
    "1x TAE Buffer" => "liquid",
    "DNA Ladder (1 kb)" => "liquid",
    "Gel Loading Dye (6x)" => "liquid",
    "Ethidium Bromide" => "liquid",
    "Sample A - Wild Type" => "liquid",
    "Sample B - Mutant" => "liquid",
    "Sample C - Heterozygous" => "liquid"
  }
  chemicals.each do |name, state|
    chem[name] = Chemical.find_or_create_by!(name: name) { |c| c.state = state }
  end

  # --- Containers ---
  containers = {}
  [
    ["Erlenmeyer Flask", "flask"],
    ["Graduated Cylinder", "graduated_cylinder"],
    ["Gel Tray", "tray"]
  ].each do |name, ctype|
    containers[name] = Container.find_or_create_by!(name: name) { |c| c.container_type = ctype }
  end

  # --- Experiment ---
  exp = Experiment.find_or_create_by!(title: "Agarose Gel Electrophoresis") do |e|
    e.description = "Separate DNA fragments by size using agarose gel electrophoresis. Prepare the gel, load samples, run the gel, and analyze band patterns."
    e.published = true
    e.status = :pending
  end

  # Assign to a school if one exists
  school = School.first
  if school
    ExperimentSchool.find_or_create_by!(experiment: exp, school: school)
  end

  # Clear existing phases
  exp.experiment_phases.destroy_all

  # --- Phase 1: Gel Preparation ---
  p1 = exp.experiment_phases.create!(
    title: "Gel Preparation",
    description: "Prepare the agarose gel by setting up the casting tray, pouring the gel, and letting it solidify.",
    position: 1
  )

  # Step 1.1: Place casting tray
  step1_1 = p1.phase_steps.create!(
    step_number: 1,
    instruction: "Place the casting tray on the workbench and seal the ends.",
    position: 1
  )
  step1_1.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Prepare the gel casting setup.",
    position: 1,
    config: { substep: "tray" }
  )

  # Step 1.2: Insert comb
  step1_2 = p1.phase_steps.create!(
    step_number: 2,
    instruction: "Insert the comb into the tray to create wells for sample loading.",
    position: 2
  )
  step1_2.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Insert comb to form wells.",
    position: 1,
    config: { substep: "comb" }
  )

  # Step 1.3: Measure and prepare agarose
  step1_3 = p1.phase_steps.create!(
    step_number: 3,
    instruction: "Measure 0.8g agarose powder and add 40mL of 1x TAE buffer in a flask.",
    position: 3
  )
  step1_3.step_actions.create!(
    action_type: :transfer,
    instruction: "Mix agarose with buffer.",
    position: 1
  )

  # Step 1.4: Heat agarose
  step1_4 = p1.phase_steps.create!(
    step_number: 4,
    instruction: "Heat the mixture until the agarose is fully dissolved and the solution is clear.",
    position: 4
  )
  step1_4.step_actions.create!(
    action_type: :instruction,
    instruction: "Observe the solution turning clear.",
    position: 1
  )

  # Step 1.5: Pour gel
  step1_5 = p1.phase_steps.create!(
    step_number: 5,
    instruction: "Pour the molten agarose into the casting tray and let it cool until solidified.",
    position: 5
  )
  step1_5.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Pour and solidify the gel.",
    position: 1,
    config: { substep: "pour" }
  )

  # Step 1.6: Remove comb
  step1_6 = p1.phase_steps.create!(
    step_number: 6,
    instruction: "Carefully remove the comb to reveal the wells. The gel is now ready.",
    position: 6
  )
  step1_6.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Remove comb to expose wells.",
    position: 1,
    config: { substep: "remove_comb" }
  )

  # Step 1.7: Place gel in chamber
  step1_7 = p1.phase_steps.create!(
    step_number: 7,
    instruction: "Place the gel into the electrophoresis chamber and cover with 1x TAE buffer.",
    position: 7
  )
  step1_7.step_actions.create!(
    action_type: :instruction,
    instruction: "Position the gel in the chamber.",
    position: 1
  )

  # --- Phase 2: Sample Loading ---
  p2 = exp.experiment_phases.create!(
    title: "Sample Loading",
    description: "Load DNA samples and ladder into the wells using a micropipette.",
    position: 2
  )

  # Step 2.1: Attach pipette tip
  step2_1 = p2.phase_steps.create!(
    step_number: 1,
    instruction: "Attach a fresh tip to the micropipette.",
    position: 1
  )
  step2_1.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Click to attach a fresh tip.",
    position: 1
  )

  # Step 2.2: Load DNA ladder
  step2_2 = p2.phase_steps.create!(
    step_number: 2,
    instruction: "Load 5µL of DNA ladder into well 1.",
    position: 2
  )
  step2_2.step_actions.create!(
    action_type: :instruction,
    instruction: "Pipette DNA ladder into first well.",
    position: 1
  )

  # Step 2.3: Load Sample A
  step2_3 = p2.phase_steps.create!(
    step_number: 3,
    instruction: "Eject the used tip, attach a fresh one, and load Sample A into well 2.",
    position: 3
  )
  step2_3.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step2_3.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step2_3.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample A into well 2.",
    position: 3,
    config: { "tip_changed" => true }
  )

  # Step 2.4: Load Sample B
  step2_4 = p2.phase_steps.create!(
    step_number: 4,
    instruction: "Eject tip, attach fresh one, and load Sample B into well 3.",
    position: 4
  )
  step2_4.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step2_4.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step2_4.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample B into well 3.",
    position: 3,
    config: { "tip_changed" => true }
  )

  # Step 2.5: Load Sample C
  step2_5 = p2.phase_steps.create!(
    step_number: 5,
    instruction: "Eject tip, attach fresh one, and load Sample C into well 4.",
    position: 5
  )
  step2_5.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step2_5.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step2_5.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample C into well 4.",
    position: 3,
    config: { "tip_changed" => true }
  )

  # --- Phase 3: Electrophoresis Run ---
  p3 = exp.experiment_phases.create!(
    title: "Electrophoresis Run",
    description: "Run the gel at 70V to separate DNA fragments by size.",
    position: 3
  )

  # Step 3.1: Set voltage
  step3_1 = p3.phase_steps.create!(
    step_number: 1,
    instruction: "Set the power supply to 70V and start the run.",
    position: 1
  )
  step3_1.step_actions.create!(
    action_type: :voltage_set,
    instruction: "Set voltage to exactly 70V.",
    position: 1,
    config: { "voltage" => 70 }
  )

  # Step 3.2: Run electrophoresis
  step3_2 = p3.phase_steps.create!(
    step_number: 2,
    instruction: "Watch the DNA fragments separate as the gel runs.",
    position: 2
  )
  step3_2.step_actions.create!(
    action_type: :gel_run,
    instruction: "Observe band migration.",
    position: 1,
    config: { "duration" => 15000 }
  )

  # --- Phase 4: Band Analysis ---
  p4 = exp.experiment_phases.create!(
    title: "Band Analysis",
    description: "Analyze the DNA band patterns under UV light and identify the samples.",
    position: 4
  )

  # Step 4.1: Visualize under UV
  step4_1 = p4.phase_steps.create!(
    step_number: 1,
    instruction: "Place the gel on the UV transilluminator and observe the bands.",
    position: 1
  )
  step4_1.step_actions.create!(
    action_type: :instruction,
    instruction: "Turn on UV light to visualize bands.",
    position: 1
  )

  # Step 4.2: Mark bands
  step4_2 = p4.phase_steps.create!(
    step_number: 2,
    instruction: "Mark the DNA bands for each sample on the gel image below.",
    position: 2
  )
  step4_2.step_actions.create!(
    action_type: :gel_band_match,
    instruction: "Click on the gel to mark band positions.",
    position: 1
  )

  # Step 4.3: Identify genotypes
  step4_3 = p4.phase_steps.create!(
    step_number: 3,
    instruction: "Based on the band patterns, identify which sample is Wild Type, Mutant, and Heterozygous.",
    position: 3
  )
  step4_3.step_actions.create!(
    action_type: :quiz_input,
    instruction: "Enter the sample name for each genotype.",
    position: 1,
    config: { "expected_answer" => "a" }
  )

  # DNA Band Configs for matching
  exp.dna_band_configs.destroy_all
  [
    { sample_name: "Ladder", well_number: 1, band_positions: [30, 70, 110, 150, 180] },
    { sample_name: "Wild Type", well_number: 2, band_positions: [50, 130] },
    { sample_name: "Mutant", well_number: 3, band_positions: [130] },
    { sample_name: "Heterozygous", well_number: 4, band_positions: [50, 90, 130] }
  ].each do |cfg|
    exp.dna_band_configs.create!(cfg)
  end

  puts "  Experiment ##{exp.id}: #{exp.title}"
  puts "  Phases: #{exp.experiment_phases.size}"
  puts "  Total steps: #{exp.experiment_phases.sum { |p| p.phase_steps.size }}"
  puts "  DNA band configs: #{exp.dna_band_configs.size}"
end
