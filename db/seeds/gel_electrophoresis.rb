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
    ["Microcentrifuge Tubes", "tube_rack"],
    ["Erlenmeyer Flask", "flask"]
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
    ["Gel Tray", "tray"],
    ["DNA Ladder Tube", "tube"],
    ["Sample A Tube", "tube"],
    ["Sample B Tube", "tube"],
    ["Sample C Tube", "tube"],
    ["Gel Well 1", "well"],
    ["Gel Well 2", "well"],
    ["Gel Well 3", "well"],
    ["Gel Well 4", "well"],
    ["Autoclave Bag", "waste"]
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

  # --- Phase 1: Lab Orientation (Label Matching) ---
  p1 = exp.experiment_phases.create!(
    title: "Lab Orientation",
    description: "Learn the names of the equipment you will use in this experiment.",
    position: 1
  )

  step1_1 = p1.phase_steps.create!(
    step_number: 1,
    instruction: "Identify the lab equipment by dragging the correct labels to each item on the bench.",
    position: 1
  )
  action1_1 = step1_1.step_actions.create!(
    action_type: :label_match,
    instruction: "Match equipment names to their pictures.",
    position: 1
  )
  [
    { label: "Casting Tray", eq_name: "Casting Tray", correct: true, pos: 1 },
    { label: "Gel Comb", eq_name: "Gel Comb", correct: true, pos: 2 },
    { label: "Electrophoresis Chamber", eq_name: "Electrophoresis Chamber", correct: true, pos: 3 },
    { label: "Power Supply", eq_name: "Power Supply", correct: true, pos: 4 },
    { label: "Micropipette", eq_name: "Micropipette (P20)", correct: true, pos: 5 },
    { label: "UV Transilluminator", eq_name: "UV Transilluminator", correct: true, pos: 6 },
    { label: "Erlenmeyer Flask", eq_name: "Erlenmeyer Flask", correct: true, pos: 7 },
    { label: "Agarose Container", eq_name: "Agarose Container", correct: true, pos: 8 }
  ].each do |lbl|
    equipment = Equipment.find_by(name: lbl[:eq_name])
    action1_1.step_action_labels.create!(
      label_text: lbl[:label],
      correct_match: lbl[:correct],
      position: lbl[:pos],
      equipment: equipment
    )
  end

  # --- Phase 2: Gel Preparation ---
  p2 = exp.experiment_phases.create!(
    title: "Gel Preparation",
    description: "Prepare the agarose gel by setting up the casting tray, pouring the gel, and letting it solidify.",
    position: 2
  )

  # Step 2.1: Place casting tray
  step2_1 = p2.phase_steps.create!(
    step_number: 1,
    instruction: "Place the casting tray on the workbench.",
    position: 1
  )
  step2_1.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Place the casting tray.",
    position: 1,
    config: { substep: "tray" }
  )

  # Step 2.2: Apply masking tape
  step2_2 = p2.phase_steps.create!(
    step_number: 2,
    instruction: "Apply masking tape to seal both open ends of the casting tray.",
    position: 2
  )
  step2_2.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Seal ends with masking tape.",
    position: 1,
    config: { substep: "tape" }
  )

  # Step 2.3: Insert comb
  step2_3 = p2.phase_steps.create!(
    step_number: 3,
    instruction: "Insert the comb into the tray to create wells for sample loading.",
    position: 3
  )
  step2_3.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Insert comb to form wells.",
    position: 1,
    config: { substep: "comb" }
  )

  # Step 2.4: Measure and prepare agarose
  step2_4 = p2.phase_steps.create!(
    step_number: 4,
    instruction: "Measure 0.8g agarose powder and add 40mL of 1x TAE buffer in a flask.",
    position: 4
  )
  step2_4.step_actions.create!(
    action_type: :transfer,
    instruction: "Mix agarose with buffer.",
    position: 1
  )

  # Step 2.5: Heat agarose
  step2_5 = p2.phase_steps.create!(
    step_number: 5,
    instruction: "Heat the mixture until the agarose is fully dissolved and the solution is clear.",
    position: 5
  )
  step2_5.step_actions.create!(
    action_type: :instruction,
    instruction: "Observe the solution turning clear.",
    position: 1
  )

  # Step 2.6: Add Ethidium Bromide
  step2_6 = p2.phase_steps.create!(
    step_number: 6,
    instruction: "Carefully add 1.5µL of Ethidium Bromide (EtBr) to the warm agarose solution.",
    position: 6
  )
  step2_6.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Add Ethidium Bromide safety warning step.",
    position: 1,
    config: { substep: "etbr" }
  )

  # Step 2.7: Pour gel
  step2_7 = p2.phase_steps.create!(
    step_number: 7,
    instruction: "Pour the molten agarose into the casting tray.",
    position: 7
  )
  step2_7.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Pour agarose into tray.",
    position: 1,
    config: { substep: "pour" }
  )

  # Step 2.8: Solidify gel (10 min)
  step2_8 = p2.phase_steps.create!(
    step_number: 8,
    instruction: "Wait 10 minutes for the gel to cool and solidify completely.",
    position: 8,
    timer_duration: 600
  )
  step2_8.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Solidify gel countdown timer.",
    position: 1,
    config: { substep: "solidify" }
  )

  # Step 2.9: Remove comb
  step2_9 = p2.phase_steps.create!(
    step_number: 9,
    instruction: "Carefully remove the comb and tape. The gel is now ready.",
    position: 9
  )
  step2_9.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Remove comb and tape to expose wells.",
    position: 1,
    config: { substep: "remove_comb" }
  )

  # Step 2.10: Place gel in chamber
  step2_10 = p2.phase_steps.create!(
    step_number: 10,
    instruction: "Place the gel into the electrophoresis chamber.",
    position: 10
  )
  step2_10.step_actions.create!(
    action_type: :instruction,
    instruction: "Position the gel in the chamber.",
    position: 10
  )

  # Step 2.11: Fill buffer
  step2_11 = p2.phase_steps.create!(
    step_number: 11,
    instruction: "Pour 1x TAE buffer into the chamber to completely cover the gel.",
    position: 11
  )
  step2_11.step_actions.create!(
    action_type: :gel_prep,
    instruction: "Cover gel with buffer in chamber.",
    position: 1,
    config: { substep: "buffer" }
  )

  # --- Phase 3: Sample Loading ---
  p3 = exp.experiment_phases.create!(
    title: "Sample Loading",
    description: "Load DNA samples and ladder into the wells using a micropipette.",
    position: 3
  )

  # Step 3.1: Attach pipette tip
  step3_1 = p3.phase_steps.create!(
    step_number: 1,
    instruction: "Attach a fresh tip to the micropipette.",
    position: 1
  )
  step3_1.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Click to attach a fresh tip.",
    position: 1
  )

  # Step 3.2: Load DNA ladder
  step3_2 = p3.phase_steps.create!(
    step_number: 2,
    instruction: "Load 5µL of DNA ladder into well 1.",
    position: 2
  )
  step3_2.step_actions.create!(
    action_type: :transfer,
    instruction: "Pipette DNA ladder into first well.",
    position: 1,
    config: { "sample" => "DNA Ladder", "source" => "DNA Ladder Tube", "target" => "Gel Well 1", "well" => 1 }
  )

  # Step 3.3: Load Sample A
  step3_3 = p3.phase_steps.create!(
    step_number: 3,
    instruction: "Eject the used tip, attach a fresh one, and load Sample A into well 2.",
    position: 3
  )
  step3_3.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step3_3.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step3_3.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample A into well 2.",
    position: 3,
    config: { "sample" => "Sample A", "source" => "Sample A Tube", "target" => "Gel Well 2", "well" => 2 }
  )

  # Step 3.4: Load Sample B
  step3_4 = p3.phase_steps.create!(
    step_number: 4,
    instruction: "Eject tip, attach fresh one, and load Sample B into well 3.",
    position: 4
  )
  step3_4.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step3_4.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step3_4.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample B into well 3.",
    position: 3,
    config: { "sample" => "Sample B", "source" => "Sample B Tube", "target" => "Gel Well 3", "well" => 3 }
  )

  # Step 3.5: Load Sample C
  step3_5 = p3.phase_steps.create!(
    step_number: 5,
    instruction: "Eject tip, attach fresh one, and load Sample C into well 4.",
    position: 5
  )
  step3_5.step_actions.create!(
    action_type: :pipette_eject,
    instruction: "Eject used tip.",
    position: 1
  )
  step3_5.step_actions.create!(
    action_type: :pipette_tip_attach,
    instruction: "Attach fresh tip.",
    position: 2
  )
  step3_5.step_actions.create!(
    action_type: :transfer,
    instruction: "Load Sample C into well 4.",
    position: 3,
    config: { "sample" => "Sample C", "source" => "Sample C Tube", "target" => "Gel Well 4", "well" => 4 }
  )

  # --- Phase 4: Electrophoresis Run ---
  p4 = exp.experiment_phases.create!(
    title: "Electrophoresis Run",
    description: "Run the gel at 70V to separate DNA fragments by size.",
    position: 4
  )

  # Step 4.1: Set voltage
  step4_1 = p4.phase_steps.create!(
    step_number: 1,
    instruction: "Set the power supply to 70V and start the run.",
    position: 1
  )
  step4_1.step_actions.create!(
    action_type: :voltage_set,
    instruction: "Set voltage to exactly 70V.",
    position: 1,
    config: { "voltage" => 70 }
  )

  # Step 4.2: Run electrophoresis
  step4_2 = p4.phase_steps.create!(
    step_number: 2,
    instruction: "Watch the DNA fragments separate as the gel runs.",
    position: 2
  )
  step4_2.step_actions.create!(
    action_type: :gel_run,
    instruction: "Observe band migration.",
    position: 1,
    config: { "duration" => 15000 }
  )

  # --- Phase 5: Band Analysis ---
  p5 = exp.experiment_phases.create!(
    title: "Band Analysis",
    description: "Analyze the DNA band patterns under UV light and identify the samples.",
    position: 5
  )

  # Step 5.1: Visualize under UV
  step5_1 = p5.phase_steps.create!(
    step_number: 1,
    instruction: "Place the gel on the UV transilluminator and observe the bands.",
    position: 1
  )
  step5_1.step_actions.create!(
    action_type: :uv_exam,
    instruction: "Turn on UV light to visualize bands.",
    position: 1
  )

  # Step 5.2: Mark bands
  step5_2 = p5.phase_steps.create!(
    step_number: 2,
    instruction: "Mark the DNA bands for each sample on the gel image below.",
    position: 2
  )
  step5_2.step_actions.create!(
    action_type: :gel_band_match,
    instruction: "Click on the gel to mark band positions.",
    position: 1
  )

  # --- Phase 6: Conclusion ---
  p6 = exp.experiment_phases.create!(
    title: "Conclusion",
    description: "Based on the band patterns, identify the genotypes of each sample.",
    position: 6
  )

  # Step 6.1: Identify genotypes
  step6_1 = p6.phase_steps.create!(
    step_number: 1,
    instruction: "Based on the band patterns, identify which sample is Wild Type, Mutant, and Heterozygous.",
    position: 1
  )
  step6_1.step_actions.create!(
    action_type: :conclusion,
    instruction: "Enter the sample name for each genotype.",
    position: 1,
    config: {
      "sample_a_expected" => "Wild Type",
      "sample_b_expected" => "Mutant",
      "sample_c_expected" => "Heterozygous"
    }
  )

  # --- Phase 7: Save Lab Report ---
  p7 = exp.experiment_phases.create!(
    title: "Save Lab Report",
    description: "Save your lab findings and download the official report.",
    position: 7
  )

  # Step 7.1: Save and download PDF
  step7_1 = p7.phase_steps.create!(
    step_number: 1,
    instruction: "Review your score and download the PDF lab report.",
    position: 1
  )
  step7_1.step_actions.create!(
    action_type: :instruction,
    instruction: "Download PDF Report.",
    position: 1
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
  # Master Quizzes
  exp.master_quizzes.destroy_all
  exp.master_quizzes.create!(
    phase_step: step2_6,
    question: "Which chemical is added to the agarose solution to make DNA bands fluoresce under UV light?",
    question_type: "mcq",
    options: ["Bromophenol Blue", "Ethidium Bromide", "Methylene Blue", "Sybr Green"],
    correct_answer: "Ethidium Bromide",
    points: 10
  )
  exp.master_quizzes.create!(
    phase_step: step5_1,
    question: "What is the net electrical charge of DNA molecules, and towards which electrode do they migrate during electrophoresis?",
    question_type: "mcq",
    options: ["Positive charge, migrating to the negative cathode", "Negative charge, migrating to the positive anode", "Neutral charge, migrating randomly", "Positive charge, migrating to the positive anode"],
    correct_answer: "Negative charge, migrating to the positive anode",
    points: 10
  )

  puts "  Experiment ##{exp.id}: #{exp.title}"
  puts "  Phases: #{exp.experiment_phases.size}"
  puts "  Total steps: #{exp.experiment_phases.sum { |p| p.phase_steps.size }}"
  puts "  DNA band configs: #{exp.dna_band_configs.size}"
end
