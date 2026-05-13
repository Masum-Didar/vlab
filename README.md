# 🧪 Virtual Chemistry Lab

A scalable, interactive **Virtual Chemistry Lab platform** built with Ruby on Rails.  
This system allows teachers to design structured experiments and students to perform them step-by-step in a simulated environment.

---

## 🚀 Project Overview

The goal of this project is to create a **safe, guided, and interactive lab experience** where:

- 👨‍🏫 Teachers can build experiments visually
- 👨‍🎓 Students can perform experiments step-by-step
- 🧠 Learning happens through structured interaction

---

## 🧩 Core Concept

The entire system is built on a **hierarchical experiment flow**:

Experiment
└── Phase
└── Phase Step
└── Step Action (Interaction Layer)


Each level breaks down the experiment into smaller, manageable, and interactive pieces.

---

## 🛠 Tech Stack

- **Backend:** Ruby on Rails 7/8
- **Frontend:** Hotwire (Turbo + Stimulus)
- **Database:** PostgreSQL
- **Authentication:** Devise
- **Authorization:** Pundit
- **Future Integration:** Three.js (3D Lab)

---

## 🧱 Database Structure

### 👤 User
Represents system users.

**Fields:**
- name
- email
- role (`student`, `faculty`)

**Relations:**
- has_many :experiment_results

---

### 🧪 Experiment
Main container for an experiment.

**Fields:**
- title
- description
- difficulty
- duration
- status
- published

**Relations:**
- has_many :experiment_phases
- has_many :phase_steps (through phases)
- has_many :experiment_chemicals
- has_many :experiment_equipments

---

### 🧩 ExperimentPhase
Represents a logical section of an experiment.

**Fields:**
- experiment_id
- title
- description
- position

**Relations:**
- belongs_to :experiment
- has_many :phase_steps

---

### 🪜 PhaseStep
Represents a single step inside a phase.

**Fields:**
- experiment_phase_id
- step_number
- instruction

**Relations:**
- belongs_to :experiment_phase
- has_many :step_actions

---

### ⚡ StepAction (Core Engine)

Represents an **interactive action** inside a step.

**Fields:**
- phase_step_id
- action_type (enum)
- instruction
- position

**Enum Types:**
- `label_match`
- `equipment_use`
- `transfer`

**Relations:**
- belongs_to :phase_step
- has_many :step_action_labels
- has_many :step_action_equipments
- has_many :step_action_transfers

---

## 🔗 Action-Specific Models

### 🏷 StepActionLabel
Used for label-image matching.

**Fields:**
- step_action_id
- label_name
- image_url

**Relations:**
- belongs_to :step_action

---

### ⚙️ StepActionEquipment
Used for equipment-based actions.

**Fields:**
- step_action_id
- equipment_id

**Relations:**
- belongs_to :step_action
- belongs_to :equipment

---

### 🔁 StepActionTransfer
Used for transfer actions.

**Fields:**
- step_action_id
- source_container_id
- target_container_id

**Relations:**
- belongs_to :step_action
- belongs_to :source_container (Container)
- belongs_to :target_container (Container)

---

## 🧪 Supporting Models

### Chemical
- name
- formula
- state
- color

---

### Equipment
- name
- category
- image_url

---

### Container
- name
- container_type
- Represents reusable lab vessels such as beakers, test tubes, flasks, measuring cylinders, and pipettes.
- Containers are not chemicals. A transfer action uses a container as a physical location and a chemical as the substance being moved.

---

### ExperimentChemical
Join table for experiment ↔ chemical

- experiment_id
- chemical_id
- quantity_default

---

### ExperimentEquipment
Join table for experiment ↔ equipment

- experiment_id
- equipment_id

---

### ExperimentResult
Stores student experiment output

- user_id
- experiment_id
- result_data (JSON)

---

## 🔄 Relationships Overview

Experiment

├── Phases

│ ├── Steps

│ │ ├── StepActions

│ │ │ ├── Labels

│ │ │ ├── Equipments

│ │ │ └── Transfers

│
├── Chemicals

└── Equipments


---

## 🎯 Step Action System (Key Feature)

This is the **heart of the system**.

Each `StepAction` defines **what the student must do**.

### Supported Action Types:

#### 🏷 Label Match
- Match correct label with image
- Helps identify chemicals/equipment

#### ⚙️ Equipment Use
- Use specific equipment based on instruction

#### 🔁 Transfer
- Move substances between containers
- Simulates real lab workflow

---

## 🧪 Experiment Setup

Before a teacher publishes an experiment, the experiment needs four setup layers:

1. **Experiment resources**
   - Add required chemicals in `Admin → Chemicals`.
   - Add required equipment in `Admin → Equipments`.
   - Link those chemicals/equipment to the experiment.

2. **Reusable containers**
   - Containers should be created initially, similar to chemicals/equipment.
   - Examples: `Beaker A`, `Beaker B`, `Test Tube 1`, `Conical Flask`, `Measuring Cylinder`, `Pipette`.
   - Containers are reusable across experiments because they describe lab vessels, not chemical stock.
   - The project seeds default containers through `db/seeds.rb`, so a fresh setup can run:

```bash
bin/rails db:seed
```

3. **Experiment flow**
   - Create the experiment.
   - Add phases.
   - Add phase steps.
   - Add step actions to each phase step.

4. **Action details**
   - `label_match`: add labels/images.
   - `equipment_use`: select equipment needed for the action.
   - `transfer`: select source container, target container, chemical, and quantity.

### Source Container vs Target Container

For a transfer action:

- **Source Container** means where the chemical starts.
- **Target Container** means where the chemical should be moved.
- **Chemical** means what substance is being transferred.
- **Quantity / Volume** means how much should be transferred.

Example:

`Transfer 10 ml HCl from Beaker A to Test Tube 1`

- Source Container: `Beaker A`
- Target Container: `Test Tube 1`
- Chemical: `HCl`
- Quantity / Volume: `10`

The source and target container must be different. This keeps the transfer action meaningful and prevents invalid setup like transferring a chemical from `Beaker A` to `Beaker A`.

---

## 🧠 Rendering Strategy

Action UI is dynamically rendered:

```ruby
def render_action_details(action)
  case action.action_type
  when "label_match"
    render "step_actions/label_match"
  when "equipment_use"
    render "step_actions/equipment_use"
  when "transfer"
    render "step_actions/transfer"
  end
end
```

---

## 🪟 Modal System (Reusable)

- Shared modal component
- Loaded dynamically via Stimulus
- Used for create/edit forms
- Partial: `shared/_modal.html.erb`

---

## 🧭 User Flow

### 👨‍🎓 Student
- Select experiment
- Follow phases and steps
- Perform actions
- Observe results

### 👨‍🏫 Teacher
- Create experiment
- Add phases
- Add steps
- Add step actions
- Configure chemicals, equipment, and transfer containers

---

## 📁 Project Structure

```text
app/
  models/
    experiment.rb
    experiment_phase.rb
    phase_step.rb
    step_action.rb
    step_action_label.rb
    step_action_equipment.rb
    step_action_transfer.rb
    chemical.rb
    equipment.rb
    container.rb

  controllers/
    admin/
      experiments_controller.rb
      step_actions_controller.rb
      containers_controller.rb

  views/
    admin/step_actions/
      _form.html.erb
      _label_match.html.erb
      _equipment_use.html.erb
      _transfer.html.erb

    shared/
      _modal.html.erb

  javascript/
    controllers/
      modal_controller.js
```

---

## 🛣 Development Roadmap

### Phase 1
- Experiment CRUD
- Phase & Step structure

### Phase 2
- StepAction system
- Label / Equipment / Transfer

### Phase 3
- Interactive UI with Stimulus

### Phase 4
- Simulation engine

### Phase 5
- 3D Lab with Three.js

---

## 🔮 Future Scope

- 🔬 Real-time simulation engine
- 🎮 Gamified learning system
- 🧠 AI-based guidance
- 🥽 VR/AR lab
- 📊 LMS integration


💡 Final Note

This is not just a CRUD app.

This is a modular experiment builder system that can evolve into a full-scale virtual lab platform.
