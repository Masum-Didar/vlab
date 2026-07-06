# Gap Analysis Report: Virtual Lab Simulator (Gel Electrophoresis)

**Analysis Date:** July 3, 2026
**Analyst:** Senior Full-Stack Solutions Architect & QA Engineer
**Source Documents:** 5 Architecture Markdown Files, Lab PDF Instructions, Reference Video, Existing Rails Implementation

---

## 1. Functional Gaps — Logic Steps & Animation Triggers

### GAP-FN-01: Micropipette Tip Management (Critical)

| Aspect | Detail |
|--------|--------|
| **Video/PDF Expectation** | Tip attach before each sample → transfer → eject into Autoclave Bag → new tip for next sample. Contamination warning if tip not changed. |
| **Architecture State** | "Tip change" mentioned briefly but no attach/eject animation, no Autoclave Bag, no contamination logic. |
| **Implementation State** | Not implemented — `lab.html.erb` shows only static HTML items. |

**Technical Solution:**
Add new `action_type` values to `StepAction`: `pipette_tip_attach`, `pipette_eject`, `pipette_transfer`. Make a `pipette_tip_attach` action mandatory before every transfer and a `pipette_eject` after. Add `tip_changed` (BOOLEAN) and `waste_bin_id` (FK) fields to `step_action_transfers`. Validate contamination server-side.

---

### GAP-FN-02: Phase 2 — Agarose Gel Preparation Step Details (High)

| Sub-step | Video/PDF Expectation | Architecture State |
|----------|----------------------|-------------------|
| Masking Tape | Attach tape to both ends of tray | Not specified |
| Gel Comb Insertion | Insert comb for well creation | Partially mentioned |
| Ethidium Bromide | Add EtBr to hot liquid agarose | Mentioned but no animation |
| Pouring | Pour carefully to avoid air bubbles | No animation or validation |
| Solidification | Wait 10 minutes (timer) | No timer |
| Comb & Tape Removal | Remove comb and tape | Steps not specified |
| Buffer Filling | Fill chamber with buffer | No animation |

**Technical Solution:**
Create individual `PhaseStep` records for each sub-step. Add new `action_type` values: `masking_tape_apply`, `comb_insert`, `ethidium_bromide_add`, `pour_liquid` (with air bubble check), `timer_wait`, `comb_remove`, `buffer_fill`. Use the existing `PhaseStep.timer_duration` field for the 10-minute solidification timer.

---

### GAP-FN-03: Phase 4 — Voltage & Power Source Sequence (Critical)

| Aspect | Detail |
|--------|--------|
| **PDF/Video** | Place lid → Power ON → Set 70V with arrow keys → Click Play → Run 1hr30min → Pause → Power OFF → Remove lid |
| **Architecture** | "Set voltage to 70V" — no arrow key mechanism, no Pause/Stop step |
| **Implementation** | Static "70 V" text in `lab.html.erb` |

**Technical Solution:**
Add `action_type: voltage_set` to `StepAction` with `config: { target_voltage: 70, input_method: "arrow_keys", tolerance: 0 }`. Use `equipment_connect` action type to verify Power Source → Chamber connection. Add separate `power_control` action type for Pause/Stop buttons. Build an arrow-key UI component on the frontend with a digital display.

---

### GAP-FN-04: DNA Band Migration Animation (High)

The PDF shows animated bands migrating downward based on fragment size with a timer progress overlay. The architecture only mentions "fast-forward" with no graphical representation or band position calculation logic.

**Technical Solution:**
Create a Canvas/Three.js component on the frontend that renders band positions in sync with the timer. Use the formula: `band_position = fragment_size / voltage × time`. Store pre-computed band positions in `experiment_results.data` JSONB field.

---

## 2. Database Gaps — PostgreSQL Schema

### GAP-DB-01: `assignments` Table — Completely Missing (Critical)

The **Experiment Management Logic** document specifies `assignments` and `classrooms` tables, but neither exists in `schema.rb`.

**Required Tables (Missing):**

```sql
CREATE TABLE classrooms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    school_id INT REFERENCES schools(id),
    faculty_id INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE assignments (
    id SERIAL PRIMARY KEY,
    classroom_id INT REFERENCES classrooms(id),
    experiment_id INT REFERENCES experiments(id),
    faculty_id INT REFERENCES users(id),
    custom_instructions TEXT,
    due_date TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Technical Solution:** Add both tables via migrations. Create `Assignment` and `Classroom` models and controllers. Add "Create Assignment" UI to the faculty dashboard.

---

### GAP-DB-02: `quiz_logs` Table — Not Implemented (Medium)

The `DATABASE_ARCHITECTURE.md` specifies a `quiz_logs` table but only `step_options` exists in `schema.rb`. A proper quiz log is needed to track student answers and scores.

**Technical Solution:**

```ruby
create_table :quiz_logs do |t|
  t.references :user, null: false, foreign_key: true
  t.references :experiment_step, null: false, foreign_key: true
  t.references :step_action, foreign_key: true
  t.text :student_answer
  t.boolean :is_correct
  t.integer :attempt_number, default: 1
  t.timestamps
end
```

---

### GAP-DB-03: `lab_activity_logs` — Audit Trail Missing (Medium)

The architecture calls this "optional but recommended," but it is essential for faculty evaluation of student performance.

**Technical Solution:**

```ruby
create_table :lab_activity_logs do |t|
  t.references :user, null: false, foreign_key: true
  t.references :lab_session, null: false, foreign_key: true
  t.references :experiment_phase, foreign_key: true
  t.references :phase_step, foreign_key: true
  t.string :action_type
  t.jsonb :metadata
  t.boolean :is_error, default: false
  t.timestamps
end
```

---

### GAP-DB-04: `experiment_results.data` — Undefined JSONB Schema (Medium)

The `data` JSONB field has no documented schema, leading to inconsistency risk.

**Technical Solution:** Define and document the JSONB structure:

```json
{
  "genotype_data": [
    { "sample_name": "DNA 1", "well_number": 3, "genotype": "Genotype-1" },
    { "sample_name": "DNA 2", "well_number": 4, "genotype": "Genotype" }
  ],
  "voltage_used": 70,
  "total_time_seconds": 5400,
  "conclusion": "Sample 1 matches TNF1...",
  "mistakes_made": ["tip_not_changed_between_well_3_and_4"]
}
```

---

### GAP-DB-05: No `admin` Role in `users.role` (Low)

The `users` table `role` enum only has `student` and `faculty`. No admin role exists.

**Technical Solution:** Add `admin` value to the role enum via migration.

---

## 3. Logic Gaps — Scientific Rule Mismatches

### GAP-LG-01: Voltage Validation Logic (Critical)

**PDF:** "Set voltage to 70 V by using arrow keys on the power source."
**Current:** Static "70 V" text — no validation that voltage is correctly set to exactly 70V.

**Technical Solution:** Implement server-side validation when saving `ExperimentResult`. Reject with `failed` status if `voltage_used != 70`. Build an arrow-key UI component on the frontend with a digital display that only allows setting 70V via Up/Down arrows.

---

### GAP-LG-02: DNA Band Matching Logic (High)

**PDF:** TNF1 = high band, TNF2 = low band. Sample band positions must be matched against these two controls to determine genotype.
**Architecture:** Only states "DNA Samples are combinations of these two" with no specific logic.

**Technical Solution:** Store band position configuration in `experiments.config` JSONB:

```json
{
  "controls": {
    "tnf1": { "band_position_mm": 45, "label": "TNF1 (Control)", "well": 1 },
    "tnf2": { "band_position_mm": 78, "label": "TNF2 (Control)", "well": 2 }
  },
  "samples": [
    { "name": "DNA Sample 1", "well": 3, "bands": [45], "correct_genotype": "Genotype-1" },
    { "name": "DNA Sample 2", "well": 4, "bands": [78], "correct_genotype": "Genotype-2" },
    { "name": "DNA Sample 3", "well": 5, "bands": [45, 78], "correct_genotype": "Genotype-3 (Heterozygous)" }
  ]
}
```

Load this configuration server-side and validate the user's selected genotype against the correct answer.

---

### GAP-LG-03: Phase Sequence Validation (Critical)

**PDF:** Each phase must be completed before advancing to the next.
**Current `lab_controller.js`:** Only shows/hides panels — no progress validation. Users can jump to Phase 4 directly.

**Technical Solution:** Implement a State Machine pattern. Track `completedPhases: Set<number>` in a Zustand/Redux store. Unlock the next phase tab only when all steps in the current phase are complete. Validate server-side in `LabSession` — Phase N+1 cannot be saved unless Phase N is complete.

---

### GAP-LG-04: Tip Contamination Logic (High)

**Video:** Contamination warning if tip not changed between samples.
**Architecture:** "Red alert message for wrong clicks" — no tip-specific logic.

**Technical Solution:** Track `currentTipId` and `lastWellLoaded` in the state machine. If `currentTipId` matches the previous sample's tip and the user attempts to load a new well, display: "Contamination Warning: You must change the pipette tip between samples!" and block the action.

---

## 4. UX/UI Gaps — User Feedback & Visual Cues

### GAP-UX-01: Real-time Error Alert System (Critical)

**Architecture:** "Red alert message" specified but not implemented.
**Current:** No alert/toast system in `lab.html.erb`.

**Technical Solution:** Create a global `Toast` component (Tailwind + Stimulus). Trigger `data-controller="toast"` on each interaction error. Add `showError(message)` and `showSuccess(message)` methods to the Stimulus controller.

---

### GAP-UX-02: Electrophoresis Progress Bar (High)

**Video:** Animated progress bar for the 1-hour-30-minute electrophoresis run.
**Current:** `timer` state mentioned in architecture but not implemented.

**Technical Solution:** Create a dedicated `TimerComponent` for Phase 4. Connect it to the Three.js scene to animate band migration synchronized with the progress bar. Configure `phase_step.timer_duration = 5400` (seconds) and display a fast-forwarded animation (1-2 seconds real time).

---

### GAP-UX-03: Micropipette Visual Feedback (High)

**Video:** Smooth animation of plunger press → liquid uptake → well dispensing.
**Current:** No Three.js animation (`lab_objects.js` has only basic geometry).

**Technical Solution:** Build a 3-step micropipette animation with Three.js (React Three Fiber): (1) Plunger press, (2) Liquid drawn into tip, (3) Dispense into well. Add corresponding `action_type` values: `pipette_plunger_press`, `pipette_draw`, `pipette_dispense`.

---

### GAP-UX-04: UV Light Dark Mode Effect (Medium)

**PDF:** UV light ON → dark background with bright glowing bands.
**Current:** Not specified.

**Technical Solution:** On entering Phase 5, change the Three.js scene background to black (`0x000000`) and add `emissive` properties to band meshes for blue/pink glow effects.

---

### GAP-UX-05: Drag-and-Drop Confirmation (Medium)

**PDF:** Phase 1 — labels lock into place and highlight when correctly matched.
**Current:** dnd-kit/React-DnD mentioned but not implemented.

**Technical Solution:** Implement Phase 1 label matching with `dnd-kit`. Set `correct_match = TRUE` and show green highlight when a label is dropped on the correct equipment. Auto-unlock Phase 2 when all items are matched.

---

### GAP-UX-06: Well Loading Visualization (Medium)

**Video:** Well color changes after each sample is loaded.
**Current:** No visual feedback.

**Technical Solution:** Create individual mesh objects for each well in the Three.js scene. Change the material color (red/blue/pink) after sample loading and display the sample name next to the well number.

---

## 5. Faculty/Admin Control Gaps

### GAP-FC-01: Faculty Experiment Assignment Workflow (Critical)

**Experiment Management Logic:** Faculty selects master template → selects class → selects quizzes → sets deadline.
**Current:** No assignment system exists. Faculty can only edit/delete experiments.

**Technical Solution:**
1. Create `Classroom` model and CRUD (scoped to school)
2. Create `Assignment` model with controller actions:
   - `new`: Faculty selects experiment, classroom, and sets deadline
   - Copy selected quizzes from master bank
3. Add "Assign Lab" button to faculty dashboard

---

### GAP-FC-02: Student Progress Monitoring Dashboard (High)

**Requirement:** Faculty needs to see each student's current phase, mistakes, and scores.
**Current:** `LabSessionsController` is basic CRUD — no analytics or progress view.

**Technical Solution:**

```ruby
class Faculty::ProgressController < ApplicationController
  def show
    @assignment = Assignment.find(params[:id])
    @students = @assignment.classroom.students.includes(:lab_sessions)
    @progress_data = @students.map do |student|
      {
        student: student,
        current_phase: student.current_phase(@assignment.experiment),
        completed: student.lab_sessions.find_by(experiment: @assignment.experiment)&.completed?,
        score: student.calculate_score(@assignment.experiment),
        mistakes: student.activity_logs_for(@assignment.experiment).where(is_error: true).count
      }
    end
  end
end
```

Display a heatmap-style table on the frontend showing per-student, per-phase progress.

---

### GAP-FC-03: Quiz Bank & Faculty Customization (High)

**Experiment Management Logic:** Master quiz bank → Faculty selects preferred questions.
**Current:** `step_actions` has `quiz_input` type but no "master bank" or faculty selection concept.

**Technical Solution:**
1. Create `master_quizzes` table (admin-controlled)
2. Create `assignment_selected_quizzes` join table (`assignment_id`, `step_action_id`)
3. Add "Select Quiz Questions" panel to the faculty assignment UI with checkboxes

---

### GAP-FC-04: Due Date & Late Submission Handling (Medium)

**Experiment Management Logic:** Deadline setting mentioned but no behavior defined for overdue submissions.

**Technical Solution:** Compare `assignments.due_date` with the current time when starting a `LabSession`. Display "This assignment is past due. Please contact your faculty." if the deadline has passed. Block session creation.

---

### GAP-FC-05: Faculty-Level Student Detail View (Medium)

**Current:** `UsersController` only shows user lists and profiles — no lab performance data visible.

**Technical Solution:** Create a `Faculty::StudentProgressController` that displays for each student:
- Current phase and step
- Step timing and status
- Quiz answers and scores
- Lab activity log (voltage, tip changes, etc.)
- Genotype selection history

---

### GAP-FC-06: CSV/PDF Export for Faculty (Low)

**Requirement:** Faculty should download the entire class's results as CSV/PDF.

**Technical Solution:** Add "Export Results" button to the faculty dashboard. Generate CSV using Ruby's built-in `csv` library or PDF using the `prawn` gem.

---

## 6. Summary — Gap Impact Matrix

| Gap ID | Category | Severity | Impact |
|--------|----------|----------|--------|
| FN-01 | Pipette Tip Management | **Critical** | Core simulation mechanic broken |
| FN-02 | Gel Preparation Details | **High** | 8 missing sub-steps break experiment |
| FN-03 | Voltage/Power Sequence | **Critical** | Scientific accuracy violated |
| FN-04 | Band Migration Animation | **High** | Core visual missing |
| DB-01 | Assignments Table | **Critical** | Faculty portal non-functional |
| DB-02 | Quiz Logs Table | **Medium** | Student assessment opaque |
| DB-03 | Activity Logs Table | **Medium** | No audit trail |
| DB-04 | Result Schema | **Medium** | Data inconsistency risk |
| DB-05 | Admin Role | **Low** | Missing user type |
| LG-01 | Voltage Validation | **Critical** | No validation |
| LG-02 | Band Matching Logic | **High** | No genotype determination |
| LG-03 | Phase Sequencing | **Critical** | Students can skip phases |
| LG-04 | Contamination Logic | **High** | Core safety lesson missing |
| UX-01 | Error Alert System | **Critical** | No user feedback |
| UX-02 | Progress Bar | **High** | Missing time visualization |
| UX-03 | Pipette Animation | **High** | Poor interaction fidelity |
| UX-04 | UV Light Effect | **Medium** | Missing visual climax |
| UX-05 | Drag-and-Drop | **Medium** | Phase 1 non-interactive |
| UX-06 | Well Loading Visual | **Medium** | No visual state change |
| FC-01 | Assign Lab Workflow | **Critical** | Faculty cannot assign labs |
| FC-02 | Progress Monitor | **High** | Faculty blind to progress |
| FC-03 | Quiz Bank | **High** | No quiz customization |
| FC-04 | Due Dates | **Medium** | No deadline enforcement |
| FC-05 | Student Detail View | **Medium** | Poor faculty visibility |
| FC-06 | CSV/PDF Export | **Low** | Missing convenience feature |

---

## 7. Recommended Action Plan (Priority Order)

| Priority | Gap ID | Action | Effort |
|----------|--------|--------|--------|
| **P0** | LG-03 | Implement Phase State Machine — foundation for all other features | 3-4 days |
| **P0** | LG-01 | Voltage validation — critical for scientific accuracy | 1-2 days |
| **P0** | UX-01 | Build global Toast/Alert system — needed for all user feedback | 1 day |
| **P0** | DB-01 + FC-01 | Create `classrooms`, `assignments` tables + faculty workflow | 5-7 days |
| **P1** | FN-01 + LG-04 | Implement micropipette tip logic with contamination validation | 4-5 days |
| **P1** | LG-02 | Build DNA band configuration & genotype matching algorithm | 3-4 days |
| **P1** | UX-02 + FN-04 | Create progress bar + band migration animation | 4-5 days |
| **P1** | FN-02 | Implement full Phase 2 gel preparation flow (8 sub-steps) | 3-4 days |
| **P2** | UX-03 | Build micropipette 3D animation (Three.js) | 5-7 days |
| **P2** | UX-05 | Implement drag-and-drop label matching (dnd-kit) | 2-3 days |
| **P2** | DB-02 + DB-03 | Add `quiz_logs` and `lab_activity_logs` tables | 1-2 days |
| **P2** | FC-02 | Build student progress monitoring dashboard | 4-5 days |
| **P3** | UX-04 + UX-06 | UV light effect + well loading visualization | 2-3 days |
| **P3** | FC-03 | Quiz bank and faculty quiz selection feature | 3-4 days |
| **P3** | FC-04 + FC-05 | Due date enforcement + student detail view | 3-4 days |
| **P4** | DB-04 + DB-05 | Document JSONB schema + add admin role | 0.5 day |
| **P4** | FC-06 | CSV/PDF export feature | 1-2 days |

**Total estimated effort:** 6-8 weeks for a full-stack developer team
**New tables required:** 5 (`classrooms`, `assignments`, `quiz_logs`, `lab_activity_logs`, `master_quizzes`)
**New frontend components:** 15+
**Critical path:** State Machine → Assignments → Pipette Logic → Band Animation
