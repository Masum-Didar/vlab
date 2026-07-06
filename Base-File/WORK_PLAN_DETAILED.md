# বিস্তারিত ওয়ার্ক প্ল্যান — Virtual Lab Simulator (Gel Electrophoresis)

---

## ১. বর্তমান ডাটাবেসের অবস্থা

### ✅ ইতিমধ্যে বিদ্যমান টেবিলসমূহ (২০টি)

| টেবিল | ডিটেইলস | স্ট্যাটাস |
|-------|----------|-----------|
| `users` | Devise auth, role (student/faculty/administrator), school_id, department_id | ✅ Complete |
| `schools` | Multi-tenant setup, subdomain | ✅ Complete |
| `departments` | Under schools | ✅ Complete |
| `experiments` | title, description, config JSONB, duration, difficulty, status, published, method_description, school_id | ✅ Complete |
| `experiment_phases` | experiment_id, title, description, position | ✅ Complete |
| `phase_steps` | experiment_phase_id, step_number, instruction, timer_duration, completion_criteria, image_url, video_url, completed_image_url | ✅ Complete |
| `step_actions` | phase_step_id, action_type (enum: 0-6), config JSONB, instruction, position | ✅ Complete |
| `step_action_labels` | step_action_id, label_text, image_url, correct_match, position | ✅ Complete |
| `step_action_equipments` | step_action_id, equipment_id, instruction, position | ✅ Complete |
| `step_action_transfers` | step_action_id, chemical_id, source_container_id, target_container_id, quantity | ✅ Complete |
| `experiment_steps` | (legacy system) experiment_id, experiment_phase_id, step_number, instruction | ⚠️ Legacy |
| `chemicals` | name, formula, state, color_hex, properties JSONB, description | ✅ Complete |
| `equipment` | name, equipment_type, description, has_one_attached :image | ✅ Complete |
| `containers` | name, container_type (beaker, test_tube, flask, etc.) | ✅ Complete |
| `experiment_chemicals` | experiment_id, chemical_id, quantity_default | ✅ Complete |
| `experiment_equipments` | experiment_id, equipment_id | ✅ Complete |
| `experiment_results` | user_id, experiment_id, data JSONB, status (started/completed/failed), school_id | ✅ Complete |
| `lab_sessions` | user_id, experiment_id, status, started_at, ended_at, school_id | ✅ Complete |
| `submissions` | user_id, experiment_id, data JSONB, status, school_id | ✅ Complete |
| `phase_items` | (legacy) experiment_phase_id, title, description, position | ⚠️ Legacy |
| `step_options` | (orphan table — no model) experiment_step_id, label, is_correct, option_type | ⚠️ Orphan |

---

## ২. নতুন টেবিল যা তৈরি করতে হবে

| # | নতুন টেবিল | কেন দরকার | কলামসমূহ |
|---|-----------|-----------|----------|
| 1 | `classrooms` | ফ্যাকাল্টি তাদের ক্লাস গ্রুপ তৈরি করবে | `id`, `name`, `school_id`, `faculty_id`, `section`, `created_at` |
| 2 | `assignments` | ফ্যাকাল্টি স্টুডেন্টদের জন্য ল্যাব অ্যাসাইন করবে | `id`, `classroom_id`, `experiment_id`, `faculty_id`, `custom_instructions`, `due_date`, `is_active`, `created_at` |
| 3 | `assignment_quizzes` | কোন অ্যাসাইনমেন্টে কোন কুইজ থাকবে | `id`, `assignment_id`, `step_action_id` |
| 4 | `master_quizzes` | অ্যাডমিনের তৈরি কুইজ ব্যাংক | `id`, `phase_step_id`, `question_text`, `options` JSONB, `correct_option`, `created_by` |
| 5 | `quiz_logs` | স্টুডেন্টের কুইজ উত্তর ও স্কোর | `id`, `user_id`, `step_action_id`, `student_answer`, `is_correct`, `attempt_number`, `created_at` |
| 6 | `lab_activity_logs` | স্টুডেন্টের প্রতিটি অ্যাকশনের লগ | `id`, `user_id`, `lab_session_id`, `experiment_phase_id`, `phase_step_id`, `action_type`, `metadata` JSONB, `is_error`, `created_at` |
| 7 | `dna_band_configs` | DNA ব্যান্ড পজিশন কনফিগারেশন | `id`, `experiment_id`, `sample_name`, `well_number`, `band_positions` JSONB, `correct_genotype`, `created_at` |

---

## ৩. টেবিলসমূহ যাদের আপডেট/মাইগ্রেশন দরকার

| টেবিল | কী যোগ/পরিবর্তন করতে হবে | কারণ |
|-------|-------------------------|------|
| `step_actions` | `action_type` enum-এ নতুন ভ্যালু: `pipette_tip_attach(7)`, `pipette_eject(8)`, `voltage_set(9)`, `power_control(10)`, `timer_wait(11)`, `uv_light_toggle(12)` | ভিডিও ও পিডিএফ-এর সব ইন্টারঅ্যাকশন কভার করতে |
| `step_action_transfers` | `tip_changed (boolean)`, `waste_bin_id (FK -> containers)` | টিপ কন্টামিনেশন লজিক ও অটোক্লেভ ব্যাগের জন্য |
| `experiments` | `config` JSONB-তে DNA ব্যান্ড কনফিগারেশন যুক্ত করতে হবে | জিনোটাইপ ম্যাচিং লজিকের জন্য |
| `equipment` | `image_url` বা Active Storage ইমেজ ঠিক করা দরকার | Drag-and-drop-এ ইকুইপমেন্টের ছবি দেখানোর জন্য |
| `phase_steps` | `animation_trigger (string)` কলাম যোগ করা | কোন স্টেপে কোন অ্যানিমেশন চলবে তা নির্ধারণের জন্য |
| `users` | Role-এ `administrator` ইতিমধ্যেই আছে (enum value 2) — শুধু UI দরকার | অ্যাডমিন প্যানেল ফিচার |

---

## ৪. Drag-and-Drop এর জন্য বিস্তারিত প্ল্যান

### লাইব্রেরি: `@hello-pangea/dnd` (recommended)

**কেন?**
- `react-beautiful-dnd`-এর অ্যাক্টিভলি মেইন্টেইনড ফর্ক
- Tailwind CSS-এর সাথে ভালো কাজ করে
- Stimulus.js-এর সাথেও ইউজ করা যায়
- টাচ সাপোর্ট (ট্যাবলেটের জন্য)

### ইমেজ কোথা থেকে আসবে?

**ডাটাবেস থেকে (Dynamic):**
- `equipment` টেবিলে `has_one_attached :image` (Active Storage) — এখানেই ইকুইপমেন্টের ছবি আপলোড করা থাকবে
- `step_action_labels` টেবিলে `image_url` ফিল্ড — লেবেল ম্যাচিং-এর জন্য আলাদা ইমেজ
- ছবি না থাকলে একটি default SVG/icon দেখানো হবে

**Static Fallback:**
- `app/assets/images/lab/` ডিরেক্টরিতে default equipment icons রাখা
- Lucide React icons (যা ইতিমধ্যে dependency তে আছে)

### Phase 1 (Lab Orientation) — Label Matching:
```js
// Data flow:
// 1. Admin creates StepAction (action_type: :label_match) in Phase 1
// 2. Creates StepActionLabels with label_text + correct_match boolean
// 3. Frontend: dnd-kit draggable labels + droppable zones on equipment images
// 4. On correct drop: green glow effect, label locks
// 5. All correct → Phase 1 complete, Phase 2 unlocks
```

### Phase 3 (Sample Loading) — Micropipette Drag:
```js
// 1. Drag micropipette to sample tube → liquid fills (pipette_draw action)
// 2. Drag micropipette to well → liquid dispenses (pipette_dispense action)
// 3. Drag tip to Autoclave Bag → tip ejects (pipette_eject action)
// 4. If step 3 skipped before next sample → "Contamination Warning"
```

---

## ৫. সম্পূর্ণ প্রোজেক্ট কমপ্লিশন টাইমলাইন

### ফেজ ১: ফাউন্ডেশন (P0) — ১৫ দিন
| কাজ | দিন | ডিটেইলস |
|-----|-----|---------|
| Phase State Machine | ৪ দিন | Zustand store, server validation, auto-unlock |
| Error Alert System | ২ দিন | Stimulus Toast controller |
| Assignments+Classrooms | ৫ দিন | ২টি নতুন টেবিল, CRUD, UI |
| Voltage Validation | ২ দিন | Arrow-key UI, server validate |
| Admin Role UI | ২ দিন | Admin dashboard access |

### ফেজ ২: কোর সিমুলেশন (P1) — ১৮ দিন
| কাজ | দিন | ডিটেইলস |
|-----|-----|---------|
| Micropipette Tip Logic | ৫ দিন | attach/eject/transfer, contamination |
| DNA Band Config+Matching | ৪ দিন | `dna_band_configs` table, algorithm |
| Progress Bar+Band Anim | ৫ দিন | Timer, Three.js band migration |
| Gel Preparation Flow | ৪ দিন | 8 sub-steps with air bubble check |

### ফেজ ৩: ইন্টারঅ্যাকশন (P2) — ১৫ দিন
| কাজ | দিন | ডিটেইলস |
|-----|-----|---------|
| Drag-and-Drop Phase 1 | ৩ দিন | dnd-kit, equipment images from DB |
| Micropipette 3D Animation | ৫ দিন | Three.js plunger→draw→dispense |
| Quiz+Activity Logs | ৩ দিন | ২টি নতুন টেবিল, logging system |
| Student Progress Dashboard | ৪ দিন | Faculty monitoring view |

### ফেজ ৪: ভিজ্যুয়াল পলিশ (P3) — ১০ দিন
| কাজ | দিন | ডিটেইলস |
|-----|-----|---------|
| UV Light+Glow Effect | ৩ দিন | Dark mode, emissive bands |
| Well Loading Visual | ২ দিন | Color change, sample labels |
| Quiz Bank+Faculty Select | ৩ দিন | Master quizzes UI |
| Due Date+Student Detail | ২ দিন | Deadline enforcement |

### ফেজ ৫: ফাইনাল (P4) — ৫ দিন
| কাজ | দিন | ডিটেইলস |
|-----|-----|---------|
| JSONB Schema Doc+Admin | ২ দিন | Document + admin UI |
| CSV/PDF Export | ৩ দিন | Faculty class export |

---

### **মোট সময়: ~৬৩ দিন (= ~৯ সপ্তাহ)**

| ফেজ | সময় | স্ট্যাটাস |
|-----|------|-----------|
| 🔴 Phase 1: Foundation | ১৫ দিন | ⏳ Pending |
| 🟠 Phase 2: Core Simulation | ১৮ দিন | ⏳ Pending |
| 🟡 Phase 3: Interactions | ১৫ দিন | ⏳ Pending |
| 🟢 Phase 4: Visual Polish | ১০ দিন | ⏳ Pending |
| 🔵 Phase 5: Final | ৫ দিন | ⏳ Pending |
| **Total** | **৬৩ দিন** | |

---

## ৬. কনক্রিট টাস্ক লিস্ট (Step-by-Step)

### টাস্ক ১: Phase State Machine

```
FILE: app/javascript/controllers/lab_controller.js (MODIFY)
- Replace simple panel show/hide with state machine
- Add Zustand store or Stimulus values for:
  - currentPhase (1-7)
  - completedSteps: Set
  - currentTipId: string
  - lastWellLoaded: number

FILE: app/controllers/experiments_controller.rb (MODIFY)
- POST run_step → validate step_completed server-side
- Check if previous phase is complete before allowing next

FILE: app/models/lab_session.rb (MODIFY)
- Add: validates :current_phase, numericality: { ... }
- Add: def complete_phase!(phase_number)
```

### টাস্ক ২: Error Alert System

```
FILE: app/javascript/controllers/alert_controller.js (NEW)
- Stimulus controller for global toast
- Methods: showError(msg), showSuccess(msg), showWarning(msg)
- Auto-dismiss after 4 seconds
- Tailwind classes: bg-red-100, border-red-400, text-red-700

FILE: app/views/layouts/application.html.erb (MODIFY)
- Add <div data-controller="alert"> container
```

### টাস্ক ৩: Assignments + Classrooms

```
FILES TO CREATE:
- db/migrate/XXXX_create_classrooms.rb
- db/migrate/XXXX_create_assignments.rb
- app/models/classroom.rb
- app/models/assignment.rb
- app/controllers/faculty/assignments_controller.rb
- app/views/faculty/assignments/new.html.erb
- app/views/faculty/assignments/index.html.erb

FLOW:
1. Faculty visits /faculty/assignments/new
2. Selects Classroom (or creates new)
3. Selects Experiment from list
4. Optionally selects specific quizzes
5. Sets due_date
6. Clicks "Assign" → saves to assignments table
7. Student sees assignment in their dashboard
```

### টাস্ক ৪: Micropipette Tip Logic

```
STEP_ACTION ENUM UPDATE:
- action_type: pipette_tip_attach (7)
- action_type: pipette_eject (8)

VALIDATION LOGIC (app/models/step_action_transfer.rb):
- Add custom validation:
  def tip_must_be_changed
    if previous_transfer && !tip_changed
      errors.add(:base, "Contamination warning: Change pipette tip!")
    end
  end
```

### টাস্ক ৫: DNA Band Configuration

```
NEW TABLE: dna_band_configs
- experiment_id (FK)
- sample_name (string) — "TNF1", "TNF2", "DNA 1", etc.
- well_number (integer) — 1-5
- band_positions (jsonb) — [45] or [45, 78]
- correct_genotype (string) — "Genotype-1", etc.

MATCHING ALGORITHM (app/models/experiment_result.rb):
def calculate_genotype_match(user_selections)
  configs = experiment.dna_band_configs.index_by(&:sample_name)
  results = user_selections.map do |selection|
    config = configs[selection.sample_name]
    { correct: selection.genotype == config.correct_genotype }
  end
end
```

---

## ৭. ফ্রন্টএন্ড JS লাইব্রেরি চেকলিস্ট

| লাইব্রেরি | কাজ | স্ট্যাটাস |
|-----------|-----|-----------|
| `@hello-pangea/dnd` | Drag-and-drop (Phase 1, Phase 3) | ❌ যোগ করতে হবে |
| `Three.js` | 3D lab scene | ✅ ইতিমধ্যে আছে |
| `Framer Motion` | Smooth transitions | ❌ যোগ করতে হবে |
| `Zustand` | State management | ❌ যোগ করতে হবে (Stimulus values ও চলবে) |
| `Lucide React` | Icons | ❌ যোগ করতে হবে (SVG fallback আছে) |
| `Stimulus.js` | Controllers | ✅ ইতিমধ্যে আছে |
| `Tailwind CSS` | Styling | ✅ ইতিমধ্যে আছে |
| `@hotwired/turbo` | Navigation | ✅ ইতিমধ্যে আছে |

---

## ৮. গিট ব্রাঞ্চ স্ট্রাটেজি

```
expariment-setup-v1 (current)
    └── feature/base-docs (architecture docs — current branch)
        └── feature/phase-state-machine (P0)
        └── feature/error-alert-system (P0)
        └── feature/assignments-classrooms (P0)
        └── feature/voltage-validation (P0)
        └── feature/pipette-logic (P1)
        └── feature/dna-band-matching (P1)
        └── feature/progress-bar-animation (P1)
        └── feature/gel-preparation-flow (P1)
        └── feature/drag-drop (P2)
        └── feature/pipette-3d-animation (P2)
        └── feature/quiz-logs (P2)
        └── feature/student-progress-dashboard (P2)
        └── feature/uv-light-effect (P3)
        └── feature/well-visual (P3)
        └── feature/quiz-bank (P3)
        └── feature/export-features (P4)
```

প্রতিটি ব্রাঞ্চ আলাদাভাবে তৈরি করে কাজ শেষে `feature/base-docs`-এ মার্জ করা হবে।

---

## ৯. ইম্পরট্যান্ট মন্তব্য

1. **Dual System Issue:** `experiment_steps` (legacy) এবং `phase_steps` (current) — দুইটি প্যারালাল সিস্টেম আছে। নতুন সব ফিচারে শুধু `phase_steps → step_actions` ব্যবহার করতে হবে।

2. **`step_options` Table:** এই টেবিলের কোনো মডেল বা মাইগ্রেশন ফাইল নেই। এটি সম্ভবত একটি ডিলিটেড মাইগ্রেশনের ভেস্টিজ। এটি ইগনোর করা যেতে পারে অথবা ক্লিন-আপ মাইগ্রেশন দিতে হবে।

3. **Equipment Images:** `equipment` টেবিলে `has_one_attached :image` (Active Storage) আছে। Drag-and-drop Phase 1-এর জন্য এই ইমেজগুলো ব্যবহার করা হবে।

4. **Role System:** `users.role` এ `administrator (2)` ইতিমধ্যেই enum তে আছে, কিন্তু তার জন্য আলাদা UI বা কন্ট্রোলার এখনও তৈরি হয়নি।
